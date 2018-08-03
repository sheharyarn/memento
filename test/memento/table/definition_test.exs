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



  describe "#build_options" do
    @opts [attributes: @attrs, type: :ordered_set, autoincrement: true]
    test "separates memento and mnesia options" do
      %{memento: memento, mnesia: mnesia} = Definition.build_options(@opts)

      assert mnesia[:type] == :ordered_set
      assert memento[:autoincrement] == true
    end


    @opts [attributes: @attrs, index: [:id], type: :bag]
    test "removes attributes key" do
      %{mnesia: opts} = Definition.build_options(@opts)

      assert opts[:type]  == :bag
      assert opts[:index] == [:id]
      refute opts[:attributes]
    end
  end



  describe "#merge_options" do
    @existing %{
      mnesia: [type: :ordered_set, index: [:id]],
      memento: [autoincrement: true],
    }
    @new [type: :set, autoincrement: false]


    test "does nothing for empty options" do
      assert @existing == Definition.merge_options(@existing, [])
    end


    test "overrides old options when specified" do
      assert %{memento: memento, mnesia: mnesia} = Definition.merge_options(@existing, @new)

      assert Keyword.get(memento, :autoincrement) == false
      assert Keyword.get(mnesia,  :type) == :set
      assert Keyword.get(mnesia,  :index) == [:id]
    end
  end


end
