defmodule Memento.Tests.Supervisor do
  use ExUnit.ClusteredCase, async: true
  use Memento.Support.Case

  import List, only: [last: 1]

  @scenario_opts [cluster_size: 3, boot_timeout: 20_000]
  @tables [Tables.Movie]

  scenario "given a healthy cluster", @scenario_opts do
    node_setup do
      node_memento_start()
    end

    test "cluster operates correctly through a netsplit", %{cluster: c} do
      n = Cluster.random_member(c)
      running_db_nodes = Cluster.call(n, :mnesia, :system_info, [:running_db_nodes])
      assert length(running_db_nodes) == 3

      Cluster.partition(c, 2)
      [minority, majority] = Cluster.partitions(c) |> Enum.sort_by(&length/1)

      {result1, _} = Cluster.call(last(majority), Memento, :transaction, [write_user(2493)])
      assert result1 == :ok

      {result2, {error, _}} =
        Cluster.call(hd(minority), Memento, :transaction, [write_user(3022)])
      assert result2 == :error
      assert error == :transaction_aborted

      Cluster.heal(c)

      {result3, _} = Cluster.call(hd(majority), Memento, :transaction, [write_user(7818)])
      assert result3 == :ok

      Cluster.map

    end
  end

  defp node_memento_start do
    child =
      {Memento.Supervisor,
       [
         nodes: Node.list(),
         strategy: Memento.Strategy.RAM,
         tables: @tables
       ]}

    Supervisor.start_link([child], strategy: :one_for_one)
  end

  defp write_user(id), do: fn Memento.Query.write(%Table.User{id: id}) end
end
