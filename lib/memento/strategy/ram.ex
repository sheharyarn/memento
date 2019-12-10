defmodule Memento.Strategy.Unsplit.RAM do
  @behaviour Memento.Strategy.Unsplit
  require Memento.Mnesia

  @wait_timeout 60_000

  @impl true
  def heal(tables, nodes \\ Node.list()) do
    :ok = Memento.stop()
    :ok = Memento.start()
    {:ok, _} = Memento.Mnesia.call(:change_config, [:extra_db_nodes, nodes])
    Enum.each(tables, fn x -> Memento.Mnesia.call(:add_table_copy, [x, node(), :ram_copies]) end)
    :ok = Memento.Mnesia.call(:wait_for_tables, [tables, @wait_timeout])
  end

  @impl true
  def recovery_type, do: :decentralized
end
