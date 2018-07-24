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



  describe "#match" do
    @table Tables.Movie
    @base {:_, :_, :_, :_}

    setup do
      movies = [
        %@table{id: 1, title: "Reservoir Dogs",   year: 1992, director: "Quentin Tarantino"},
        %@table{id: 2, title: "Rush",             year: 1991, director: "Lili Zanuck"},
        %@table{id: 3, title: "Jurassic Park",    year: 1993, director: "Steven Spielberg"},
        %@table{id: 4, title: "Kill Bill",        year: 2003, director: "Quentin Tarantino"},
        %@table{id: 5, title: "Pulp Fiction",     year: 1994, director: "Quentin Tarantino"},
        %@table{id: 6, title: "Rush",             year: 2013, director: "Ron Howard"},
        %@table{id: 7, title: "Jaws",             year: 1975, director: "Steven Spielberg"},
        %@table{id: 8, title: "Schindler's List", year: 1993, director: "Steven Spielberg"},
      ]

      Memento.Table.create(@table)
      Support.Mnesia.transaction fn ->
        Enum.map(movies, &Query.write/1)
      end

      :ok
    end


    test "raises error when the no. of items in the tuple don't match" do
      assert_raise(Memento.Error, ~r/not equal to .* attributes/i, fn ->
        Support.Mnesia.transaction fn ->
          Query.match(@table, {:_, :_})
        end
      end)
    end


    test "returns all records for 'ignore all' pattern" do
      Support.Mnesia.transaction fn ->
        movies = Query.match(@table, @base)

        assert length(movies) == 8
        Enum.each(movies, &(assert %@table{} = &1))
      end
    end


    test "returns all records that match a specific attribute" do
      Support.Mnesia.transaction fn ->
        assert [%{title: "Jaws", year: 1975}] =
          Query.match(@table, {:_, :_, 1975, :_})

        assert [%{title: "Rush"}, %{title: "Rush"}] =
          Query.match(@table, {:_, "Rush", :_, :_})
      end
    end


    test "returns all records that match multiple attributes" do
      Support.Mnesia.transaction fn ->
        assert [%{title: "Jurassic Park"}, %{title: "Schindler's List"}] =
          Query.match(@table, {:_, :_, 1993, "Steven Spielberg"})
      end
    end
  end

end

