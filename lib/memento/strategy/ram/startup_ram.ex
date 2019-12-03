defmodule Memento.Strategy.Startup.RAM do
  @behaviour Memento.Strategy.Startup
  require Memento.Mnesia

  @wait_timeout 60_000

  @impl true
  def execute(tables, nodes \\ Node.list()) do
    {:ok, _} = Memento.Mnesia.call(:change_config, [:extra_db_nodes, nodes])

    Enum.each(tables, fn x ->
      case Memento.Table.create(x) do
        :ok ->
          :ok

        {:error, {:already_exists, _}} ->
          Memento.Mnesia.call(:add_table_copy, [x, node(), :ram_copies])

        _ ->
          throw(x)
      end
    end)

    Memento.Mnesia.call(:wait_for_tables, [tables, @wait_timeout])
  end
end
