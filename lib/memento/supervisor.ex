defmodule Memento.Supervisor do
  @moduledoc """
  Module for supervising the database lifecycle

  `Memento.Supervisor` provides an easy-to-use, stateful, management
  layer to your application via OTP supervisory norms. You can add
  the Supervisor directly to your `Application.start` like this:

  ```
    {Memento.Supervisor,
     [
       nodes: Node.list(),
       strategy: Memento.Strategy.RAM,
       tables: @mnesia_tables
     ]}
  ```

  Once added, this module:

    1. Integrates database supervision into your application tree
    2. Subscribes to `:mnesia` system events
    3. Starts up Memento per the provided strategy
    4. Monitors and automatically performs recovery (eg, netsplits) per the provided strategy

  """

  use GenServer

  @type config :: [nodes: [node()], strategy: module(), tables: [Memento.Table.name()]]

  @doc """
  Start a `Memento.Supervisor`
  """
  @spec start_link(config) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(config) when is_list(config) do
    GenServer.start_link(__MODULE__, config, name: Memento.Supervisor)
  end

  @doc """
  Supervisor GenServer Init

  Start Memento, execute provided startup strategy, and
  subscribe to Mnesia system events.
  """
  @impl true
  def init(config) do
    state = Enum.into(config, %{})
    :ok = state.strategy.startup(state.tables, state.nodes)
    {:ok, _} = :mnesia.subscribe(:system)
    {:ok, state}
  end

  @doc """
  Heal, centralized, triggered by `inconsistent_database` events
  """
  @impl true
  def handle_info({:mnesia_system_event, {:inconsistent_database, _context, _node}}, state) do
    if state.strategy.recovery_type() == :centralized do
      state.strategy.unsplit(state.tables, state.nodes)
    end

    {:noreply, state}
  end

  @doc """
  Heal, decentralized, triggered by `minority_write_attempt` events

  Only attempt rejoin when other nodes come back into view.

  @TODO: consider `Process.send_after` timer loops for empty
  Node.list() cases. Otherwise the node could remain split
  indefinitely in low write volume cases.
  """
  @impl true
  def handle_info({:mnesia_system_event, {:mnesia_user, {:minority_write_attempt, _node}}}, state) do
    if state.strategy.recovery_type() == :decentralized and length(Node.list()) > 0 do
      state.strategy.unsplit(state.tables, state.nodes)
    end

    {:noreply, state}
  end

  @doc """
  Ignore all other system events
  """
  @impl true
  def handle_info({:mnesia_system_event, _event}, state), do: {:noreply, state}
end
