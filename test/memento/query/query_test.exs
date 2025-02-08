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


    test "raises error when primary key is nil" do
      assert_raise(Memento.Error, ~r/cannot have a nil primary key/i, fn ->
        Support.Mnesia.transaction fn ->
          Query.write(%@table{name: :some_value})
        end
      end)
    end


    test "writes the record to mnesia" do
      Support.Mnesia.transaction fn ->
        record = %@table{id: :some_id, name: :some_name}
        assert record == Query.write(record)
        assert [{@table, :some_id, :some_name}] = :mnesia.read(@table, :some_id)
      end
    end


    test "overwrites a previous record with same key" do
      Support.Mnesia.transaction fn ->
        %{id: :key, name: :old_value} = Query.write(%@table{id: :key, name: :old_value})
        %{id: :key, name: :new_value} = Query.write(%@table{id: :key, name: :new_value})

        assert [{@table, :key, :new_value}] = :mnesia.read(@table, :key)
      end
    end
  end



  describe "#write (with autoincrement enabled)" do
    @table Tables.Movie
    setup(do: Memento.Table.create(@table))


    test "it writes as usual if a key is specified" do
      Support.Mnesia.transaction! fn ->
        record = %@table{id: 100, title: "Watchmen", director: "Zack Snyder", year: 2009}
        assert %{id: 100} = Query.write(record)
      end
    end


    test "it assigns key '1' if no existing records exist and key is nil" do
      Support.Mnesia.transaction! fn ->
        assert [] = Query.all(@table)
        assert %{id: 1} = Query.write(%@table{title: "Watchmen"})
        assert [%{id: 1}] = Query.all(@table)
      end
    end


    test "it automatically assigns the next key when key is nil" do
      Support.Mnesia.transaction! fn ->
        assert []  = Query.all(@table)

        assert %{id: 10} = Query.write(%@table{title: "Watchmen", id: 10})
        assert %{id: 11} = Query.write(%@table{title: "Deadpool"})
        assert %{id: 12} = Query.write(%@table{title: "Avengers"})
        assert %{id: 13} = Query.write(%@table{title: "Ragnarok"})

        assert %{id: 10, title: "Watchmen"} = Query.read(@table, 10)
        assert %{id: 11, title: "Deadpool"} = Query.read(@table, 11)
        assert %{id: 12, title: "Avengers"} = Query.read(@table, 12)
        assert %{id: 13, title: "Ragnarok"} = Query.read(@table, 13)
      end
    end


    test "it assigns the next numeric key even if the last key used is not an integer" do
      Support.Mnesia.transaction! fn ->
        assert []  = Query.all(@table)

        assert %{id: 10}      = Query.write(%@table{title: "Watchmen", id: 10})
        assert %{id: :xyz}    = Query.write(%@table{title: "Deadpool", id: :xyz})
        assert %{id: "hello"} = Query.write(%@table{title: "Ragnarok", id: "hello"})
        assert %{id: -100}    = Query.write(%@table{title: "Punisher", id: -100})
        assert %{id: 11}      = Query.write(%@table{title: "Avengers"})

        assert %{id: 10, title: "Watchmen"} = Query.read(@table, 10)
        assert %{id: 11, title: "Avengers"} = Query.read(@table, 11)
      end
    end
  end



  describe "#match" do
    @table Tables.Movie
    @base {:_, :_, :_, :_}

    setup do
      Memento.Table.create(@table)
      @table.seed
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

        assert length(movies) == 12
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



  describe "#all" do
    @table Tables.Movie

    setup do
      Memento.Table.create(@table)
      @table.seed
    end

    test "returns all records for a table" do
      Support.Mnesia.transaction fn ->
        movies = Query.all(@table)

        assert length(movies) == 12
        Enum.each(movies, &(assert %@table{} = &1))
      end
    end
  end



  describe "#delete" do
    @table Tables.Email
    @key 2

    setup do
      Memento.Table.create(@table)
      @table.seed
    end

    test "deletes all records for given key" do
      all = fn -> :mnesia.match_object({@table, @key, :_}) end

      Support.Mnesia.transaction fn ->
        assert length(all.()) == 3
        assert :ok = Query.delete(@table, @key)
        assert length(all.()) == 0
      end
    end
  end



  describe "#delete_record" do
    @table Tables.Email
    @key 2

    setup do
      Memento.Table.create(@table)
      @table.seed
    end

    test "deletes a specific record" do
      all = fn -> :mnesia.match_object({@table, @key, :_}) end
      record = %@table{user_id: 2, email: "user.2@example.com"}

      Support.Mnesia.transaction fn ->
        assert length(all.()) == 3
        assert :ok = Query.delete_record(record)
        assert length(all.()) == 2
      end
    end
  end



  describe "#select" do
    @table Tables.Movie

    setup do
      Memento.Table.create(@table)
      @table.seed
    end


    test "returns all records for empty guard" do
      Support.Mnesia.transaction fn ->
        movies = Query.select(@table, [])

        assert length(movies) == 12
        Enum.each(movies, &(assert %@table{} = &1))
      end
    end


    test "returns all records that match a specific attribute" do
      Support.Mnesia.transaction fn ->
        assert [%{title: "Jaws", year: 1975}] =
          Query.select(@table, {:==, :year, 1975})

        assert [%{title: "Rush"}, %{title: "Rush"}] =
          Query.select(@table, {:==, :title, "Rush"})
      end
    end


    test "returns all records that match multiple attributes" do
      {:ok, movies} =
        Support.Mnesia.transaction fn ->
          Query.select(@table, [
            {:==, :year, 1993},
            {:==, :director, "Steven Spielberg"},
          ])
        end

      assert [%{title: "Jurassic Park"}, %{title: "Schindler's List"}] = movies
    end


    test "works with complex nested guards" do
      guards =
        {:and,
          {:>=, :year, 2010},
          {:or,
            {:==, :director, "Quentin Tarantino"},
            {:==, :director, "Steven Spielberg"},
          }
        }

      {:ok, movies} =
        Support.Mnesia.transaction fn ->
          Query.select(@table, guards)
        end

      Enum.each(movies, fn m ->
        assert m.year > 2010
        assert m.director in ["Quentin Tarantino", "Steven Spielberg"]
      end)
    end
  end



  describe "#select_raw" do
    @table Tables.Movie
    @match_all [{ @table.__info__().query_base, [], [:"$_"] }]

    setup do
      Memento.Table.create(@table)
      @table.seed
    end


    test "Converts to structs when coerce is true" do
      Support.Mnesia.transaction fn ->
        records = Query.select_raw(@table, @match_all, coerce: true)

        assert is_list(records)
        assert [%@table{} | _rest] = records
      end
    end


    test "Returns original tuple records when coerce is false" do
      Support.Mnesia.transaction fn ->
        results = Query.select_raw(@table, @match_all, coerce: false)
        head = hd(results)

        assert is_list(results)
        assert {@table, _, _, _, _} = head
      end
    end


    test "Returns tuple with cont term when limit is non-nil and coerce is false" do
      Support.Mnesia.transaction fn ->
        results = Query.select_raw(@table, @match_all, limit: 5, coerce: false)

        assert {records, cont} = results
        assert is_list(records)
        assert length(records) == 5
        assert {:mnesia_select, _, _, _, _, _, _, _, _, _} = cont
        assert {@table, _, _, _, _} = hd(records)
      end
    end


    test "Returns just the records when limit is non-nil and coerce is true" do
      Support.Mnesia.transaction fn ->
        records = Query.select_raw(@table, @match_all, limit: 5, coerce: true)

        assert is_list(records)
        assert length(records) == 5
        assert [%@table{} | _rest] = records
      end
    end


    test "Returns empty list when nothing matches and limit is non-nil" do
      match_none = [{ @table.__info__().query_base, [{:==, :id, :invalid}], [:"$_"] }]

      Support.Mnesia.transaction fn ->
        assert [] = Query.select_raw(@table, match_none, limit: 5)
      end
    end
  end

end

