defmodule Memento.Tests.Query do
  use Memento.Support.Case
  alias Memento.Query


  describe "#read" do
    @table Tables.User

    setup do
      Memento.Table.create(@table)
      Support.Mnesia.transaction(fn ->
        :mnesia.write({@table, 1, :a})
        :mnesia.write({@table, 2, :b})
        :mnesia.write({@table, 3, :c})
      end)

      :ok
    end


    test "returns record struct when an item exists for given key" do
      Support.Mnesia.transaction fn ->
        assert %@table{id: 1, name: :a} = Query.read(@table, 1)
        assert %@table{id: 2, name: :b} = Query.read(@table, 2)
        assert %@table{id: 3, name: :c} = Query.read(@table, 3)
      end
    end


    test "returns nil when no record is found" do
      Support.Mnesia.transaction fn ->
        refute Query.read(@table, 4)
        refute Query.read(@table, 5)
        refute Query.read(@table, 6)
      end
    end
  end



  describe "#write" do
    @table Tables.User
    setup(do: Memento.Table.create(@table))

    test "writes the record to mnesia" do
      Support.Mnesia.transaction fn ->
        assert :ok = Query.write(%@table{id: :some_id, name: :some_name})
        assert [{@table, :some_id, :some_name}] = :mnesia.read(@table, :some_id)
      end
    end

    test "overwrites a previous record with same key" do
      Support.Mnesia.transaction fn ->
        :ok = Query.write(%@table{id: :key, name: :old_value})
        :ok = Query.write(%@table{id: :key, name: :new_value})

        assert [{@table, :key, :new_value}] = :mnesia.read(@table, :key)
      end
    end
  end


end

