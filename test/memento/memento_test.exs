defmodule Memento.Tests.Memento do
  use Memento.Support.Case


  describe "#add_nodes" do
    test "raises error when an atom is not passed" do
      assert_raise(Memento.Error, ~r/invalid node list/i, fn ->
        Memento.add_nodes(123)
      end)

      assert_raise(Memento.Error, ~r/invalid node list/i, fn ->
        Memento.add_nodes([:valid_node@host, "invalid_node@host"])
      end)
    end


    test "returns ok for valid atom list" do
      assert {:ok, []} = Memento.add_nodes(:nonexistent_node@host)
    end
  end

end
