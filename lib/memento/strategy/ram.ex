defmodule Memento.Strategy.RAM do
  @behaviour Memento.Strategy
  require Memento.Mnesia

  @wait_timeout 60_000

  @impl true
  def startup(tables, nodes \\ Node.list()) do
    :ok = Memento.start()
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
