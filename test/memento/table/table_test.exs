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


    test "raises error if module is not a memento table" do
      assert_raise(Memento.Error, ~r/not a memento table/i, fn ->
        Memento.Table.create(RandomModule)
      end)
    end
  end



  describe "#delete" do
  end

end
