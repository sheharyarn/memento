defmodule Memento.Supervisor do
  @moduledoc """
  Module for supervising the database lifecycle

  `Memento.Supervisor` provides an easy-to-use, stateful, management
  layer to your application via OTP supervisory norms. You can add
  the Supervisor directly to your `Application.start` like this:

  ```
    {Memento.Supervisor,
     [
       startup: Memento.Strategy.Startup.RAM,
       unsplit: Memento.Strategy.Unsplit.RAM,
       tables: @mnesia_tables
     ]}
  ```

  One added, this module:

    1. Integrates database supervision into your application tree
    2. Subscribes to `:mnesia` system events
    3. Starts up Memento per the provided strategy
    4. Monitors and automatically performs recovery (eg, netsplits) per the provided strategy

  """

  use GenServer
  require Memento.Mnesia

  @doc """
  Supervisor GenServer Init

  Start Memento, execute provided startup strategy, and
  subscribe to Mnesia system events.
  """
  @impl true
  def init(config) do
    Memento.start()
    config.startup.execute(config.tables, config.nodes)
    Memento.Mnesia.call(:subscribe, :system)
    {:ok, config}
  end

  @doc """
  Heal, triggered by observed `inconsistent_database` events
  """
  @impl true
  def handle_info({:mnesia_system_event, {:inconsistent_database, _context, _node}}, state) do
    # @TODO: traditional unsplit behavior
    {:noreply, state}
  end

  @doc """
  Heal, triggered by observed `minority_write_attempt` events

  Only attempt rejoin when other nodes come back into view.

  @TODO: consider `Process.send_after` timer loops for empty
  Node.list() cases. Otherwise the node could remain split
  indefinitely in low write volume cases.
  """
  @impl true
  def handle_info({mnesia_user, {:mnesia_system_event, {:minority_write_attempt, _}}}, state) do
    IO.puts(mnesia_user)

    if state.unsplit.recovery_type() == :decentralized and length(Node.list()) > 0 do
      state.unsplit.heal(state.tables, state.nodes)
    end

    {:noreply, state}
  end
end
