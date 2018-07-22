defmodule Memento.Tests.Query.Data do
  use Memento.Support.Case
  alias Memento.Query.Data


  describe "#cast" do
    @table Tables.User
    test "converts mnesia tuples to memento data structs" do
      assert %@table{id: :key, name: :value} =
        Data.cast({@table, :key, :value})
    end


    @table RandomModule
    test "raises error for invalid memento tables" do
      assert_raise(UndefinedFunctionError, ~r/__info__\/0 is undefined/i, fn ->
        Data.cast({@table, :key, :value})
      end)
    end
  end


end
