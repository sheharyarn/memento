defmodule Memento.Tests.Query.Data do
  use Memento.Support.Case
  alias Memento.Query.Data

  describe "#load" do
    @table Tables.User
    test "converts mnesia tuples to memento data structs" do
      assert %@table{id: :key, name: :value} =
               Data.load({@table, :key, :value})
    end

    @table RandomModule
    test "raises error for invalid memento tables" do
      assert_raise(UndefinedFunctionError, ~r/__info__\/0 is undefined/i, fn ->
        Data.load({@table, :key, :value})
      end)
    end
  end

  describe "#dump" do
    @table Tables.User
    test "converts memento structs to mnesia tuples" do
      assert {@table, :some_id, :some_name} =
               Data.dump(%@table{id: :some_id, name: :some_name})
    end

    @table RandomModule
    test "raises error for invalid memento tables" do
      assert_raise(FunctionClauseError, ~r/no .* clause matching/i, fn ->
        Data.dump({@table, :some_id, :some_name})
      end)
    end
  end
end
