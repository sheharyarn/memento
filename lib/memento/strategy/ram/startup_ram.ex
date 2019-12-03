defmodule Memento.Strategy.Startup.RAM do
  @behaviour Memento.Strategy.Startup
  require Memento.Mnesia

  @wait_timeout 60_000

  @impl true
  def execute(tables, nodes \\ Node.list()) do
    {:ok, _} = Memento.Mnesia.call(:change_config, [:extra_db_nodes, nodes])
    Enum.each(tables, fn x -> Memento.Table.create(x) |> handle_result(x) end)
    :ok = Memento.Mnesia.call(:wait_for_tables, [tables, @wait_timeout])
  end

  defp handle_result(:ok, _table), do: :ok

  defp handle_result({:error, {:already_exists, _}}, table) do
    Memento.Mnesia.call(:add_table_copy, [table, node(), :ram_copies])
  end

  defp handle_result(error, _), do: throw(error)
end
