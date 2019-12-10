defmodule Memento.Strategy.RAM do
  @moduledoc """
  Module for using Memento in a RAM-based configuration

  `Memento.Strategy.RAM` starts Memento in a RAM-only
  configuration. Each node joined to the cluster attempts
  to create the desired tables on startup, but only the
  first succeeds. The others detect the existing tables
  on failure and then add them from remote node(s).

  Unsplit is handled in a decentralized manner. In the
  event of a netsplit, the minority node(s) are aware of
  their situation and refuse to write. They attempt rejoin
  to the majority on the write failures.
  """

  @behaviour Memento.Strategy
  require Memento.Mnesia

  @wait_timeout 60_000

  @impl true
  def startup(tables, nodes \\ Node.list()) do
    {:ok, _} = Memento.Mnesia.call(:change_config, [:extra_db_nodes, nodes])
    Enum.each(tables, fn x -> Memento.Table.create(x) |> handle_result(x) end)
    :ok = Memento.Mnesia.call(:wait_for_tables, [tables, @wait_timeout])
  end

  @impl true
  def unsplit(tables, nodes \\ Node.list()) do
    :ok = Memento.stop()
    :ok = Memento.start()
    {:ok, _} = Memento.Mnesia.call(:change_config, [:extra_db_nodes, nodes])
    Enum.each(tables, fn x -> Memento.Mnesia.call(:add_table_copy, [x, node(), :ram_copies]) end)
    :ok = Memento.Mnesia.call(:wait_for_tables, [tables, @wait_timeout])
  end

  @impl true
  def recovery_type, do: :decentralized

  ### Private Functions ###

  defp handle_result(:ok, _table), do: :ok

  defp handle_result({:error, {:already_exists, _}}, table) do
    Memento.Mnesia.call(:add_table_copy, [table, node(), :ram_copies])
  end

  defp handle_result(error, _), do: throw(error)
end
