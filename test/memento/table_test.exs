defmodule Memento.Tests.Table do
  use ExUnit.Case


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
  end


end
