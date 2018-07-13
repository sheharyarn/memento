defmodule Memento.Tests.Table.Definition do
  use Memento.Support.Case
  alias Memento.Table.Definition


  @table Meta.User
  @attrs [:id, :name, :email]


  describe "#build_base" do
    @expected {@table, :"$1", :"$2", :"$3"}
    test "returns a tuple of match spec variables against a list of attrs" do
      assert @expected == Definition.build_base(@table, @attrs)
    end
  end


  describe "#build_map" do
    @expected %{id: :"$1", name: :"$2", email: :"$3"}
    test "returns a map with attributes as keys and match spec variables as values" do
      assert @expected == Definition.build_map(@attrs)
    end
  end


  describe "#struct_fields" do
    @expected [{:__meta__, Memento.Table} | @attrs]
    test "prepends attribute list with :__meta__ field" do
      assert @expected == Definition.struct_fields(@attrs)
    end
  end

end
