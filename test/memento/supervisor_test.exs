defmodule Memento.Tests.Supervisor do
  use ExUnit.ClusteredCase, async: true

  @scenario_opts [cluster_size: 3, boot_timeout: 20_000]
  @tables [Tables.User]

  scenario "given a healthy cluster", @scenario_opts do
    node_setup do
      node_memento_start()
    end

    test "mnesia up on three nodes", %{cluster: c} do
      n = Cluster.random_member(c)
      running_db_nodes = Cluster.call(n, :mnesia, :system_info, [:running_db_nodes])
      assert length(running_db_nodes) == 3
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
end
