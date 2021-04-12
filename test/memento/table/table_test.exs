defmodule Memento.Tests.Table do
  use Memento.Support.Case


  describe "__using__" do
    test "works with simple definition" do
      defmodule Meta.Simple do
        use Memento.Table, attributes: [:id, :username]
      end
    end


    test "works with valid options" do
      defmodule Meta.AllOptions do
        use Memento.Table,
          attributes: [:id, :username],
          index: [:username],
          type: :ordered_set
      end
    end


    test "works with sigils" do
      defmodule Meta.SupportsSigils do
        use Memento.Table, attributes: ~w[id username]a
      end

      assert Meta.SupportsSigils.__info__()[:attributes] == [:id, :username]
    end


    test "works with module attributes" do
      defmodule Meta.SupportsAttributes do
        @table_attrs [:id, :username]
        use Memento.Table, attributes: @table_attrs
      end

      assert Meta.SupportsAttributes.__info__()[:attributes] == [:id, :username]
    end


    test "raises error for invalid options" do
      assert_raise(Memento.Error, ~r/invalid options/i, fn ->
        defmodule MetaApp.InvalidOptions do
          use Memento.Table, :invalid
        end
      end)
    end


    test "raises error if attributes are not specifed" do
      assert_raise(Memento.Error, ~r/attributes not specified/i, fn ->
        defmodule MetaApp.NoAttributes do
          use Memento.Table
        end
      end)
    end


    test "raises error for invalid attributes" do
      assert_raise(Memento.Error, ~r/invalid attributes/i, fn ->
        defmodule MetaApp.InvalidAttributes do
          use Memento.Table, attributes: :invalid
        end
      end)

      assert_raise(Memento.Error, ~r/invalid attributes/i, fn ->
        defmodule MetaApp.InvalidAttributes do
          use Memento.Table, attributes: [1,2,3]
        end
      end)
    end


    test "raises error for invalid table type" do
      assert_raise(Memento.Error, ~r/invalid.*type/i, fn ->
        defmodule MetaApp.InvalidType do
          use Memento.Table,
            attributes: [:id, :username],
            type: :invalid
        end
      end)
    end
  end




  describe "#create" do
    @table Tables.User

    test "creates an mnesia table from memento definition" do
      assert :ok = Memento.Table.create(@table)
    end


    test "returns :error if the table already exists" do
      assert {:atomic, :ok} = :mnesia.create_table(@table, [])
      assert {:error, {:already_exists, _}} = Memento.Table.create(@table)
    end


    test "returns :error if autoincrement is used without :ordered_set (options)" do
      assert {:error, {:autoincrement, message}} = Memento.Table.create(@table, autoincrement: true)
      assert message =~ ~r/can only be used with.*ordered.set/i
    end


    test "returns :error if autoincrement is used without :ordered_set (definition)" do
      defmodule MetaApp.AutoincrementBag do
        use Memento.Table,
          attributes: [:id, :name],
          autoincrement: true
      end

      assert {:error, {:autoincrement, message}} = Memento.Table.create(MetaApp.AutoincrementBag)
      assert message =~ ~r/can only be used with.*ordered.set/i
    end


    test "raises error if module is not a memento table" do
      assert_raise(Memento.Error, ~r/not a memento table/i, fn ->
        Memento.Table.create(RandomModule)
      end)
    end
  end




  describe "#create!" do
    @table Tables.User

    test "returns :ok when everything goes as expected" do
      assert :ok = Memento.Table.create!(@table)
    end


    test "raises AlreadyExistsError if table already exists" do
      assert {:atomic, :ok} = :mnesia.create_table(@table, [])
      assert_raise(Memento.AlreadyExistsError, ~r/already exists/i, fn ->
        Memento.Table.create!(@table)
      end)
    end


    test "raises InvalidOperationError when autoincrement is used with a type other than :ordered_set" do
      defmodule MetaApp.AutoincrementBagBang do
        use Memento.Table,
          attributes: [:id, :name],
          autoincrement: true
      end

      assert_raise(Memento.InvalidOperationError, ~r/can only be used with.*ordered.set/i, fn ->
        Memento.Table.create!(MetaApp.AutoincrementBagBang)
      end)
    end
  end




  describe "#delete" do
    @table Tables.User

    test "raises error if module is not a memento table" do
      assert_raise(Memento.Error, ~r/not a memento table/i, fn ->
        Memento.Table.delete(RandomModule)
      end)
    end


    test "deletes an mnesia table from memento definition" do
      assert {:atomic, :ok} = :mnesia.create_table(@table, [])
      assert :ok = Memento.Table.delete!(@table)
    end


    test "returns :error if the table does not exists" do
      assert_raise(Memento.DoesNotExistError, ~r/does not exist/i, fn ->
        Memento.Table.delete!(@table)
      end)
    end
  end




  describe "#delete!" do
    @table Tables.User


    test "deletes an mnesia table from memento definition" do
      assert {:atomic, :ok} = :mnesia.create_table(@table, [])
      assert :ok = Memento.Table.delete!(@table)
    end


    test "raises errors if the table does not exists" do
      assert {:error, {:no_exists, _}} = Memento.Table.delete(@table)
    end
  end




  describe "#info" do
    @table Tables.User
    @key   :type

    setup(do: Memento.Table.create(@table))

    test "raises error if module is not a memento table" do
      assert_raise(Memento.Error, ~r/not a memento table/i, fn ->
        Memento.Table.info(RandomModule)
      end)
    end


    test "returns table information" do
      assert Memento.Table.info(@table) == :mnesia.table_info(@table, :all)
    end


    test "returns specific table information if key is given" do
      assert Memento.Table.info(@table, @key) == :mnesia.table_info(@table, @key)
    end
  end




  describe "#wait_for_tables" do
    @table Tables.User
    @timeout 5000

    test "returns :ok almost immediately when table is ready" do
      Memento.Table.create(@table)

      assert Memento.Table.wait_for_tables([@table]) == :mnesia.wait_for_tables([@table], @timeout)
    end
  end




  describe "#clear" do
    @table Tables.User
    @key_empty :"$end_of_table"

    setup(do: Memento.Table.create(@table))

    test "raises error if module is not a memento table" do
      assert_raise(Memento.Error, ~r/not a memento table/i, fn ->
        Memento.Table.clear(RandomModule)
      end)
    end


    test "returns ok and deletes all records in the table" do
      key_real = 1
      :mnesia.transaction(fn ->
        :mnesia.write({@table, key_real, :user})
      end)

      assert key_real == get_first_key()
      assert :ok = Memento.Table.clear(@table)
      assert @key_empty == get_first_key()
    end


    test "returns ok even if there is nothing in the table" do
      assert :ok = Memento.Table.clear(@table)
      assert @key_empty == get_first_key()
    end


    test "returns :error if the table does not exists" do
      Memento.Table.delete(@table)
      assert {:error, {:no_exists, _}} = Memento.Table.clear(@table)
    end


    defp get_first_key do
      {:atomic, key} =
        :mnesia.transaction(fn -> :mnesia.first(@table) end)

      key
    end
  end




  describe "#callback:__info__" do
    @table Tables.User


    test "it returns important meta information about the table" do
      assert info = @table.__info__()

      assert info.meta == Memento.Table
      assert info.primary_key == :id
      assert info.query_map
      assert info.query_base

      assert is_atom(info.type)
      assert is_list(info.attributes)
      assert is_map(info.options)
      assert is_integer(info.size)
    end


    test "it contains both Mnesia and Memento Options" do
      assert options = @table.__info__().options

      assert is_map(options)
      assert Keyword.keyword?(options.mnesia)
      assert Keyword.keyword?(options.memento)
    end
  end


end
