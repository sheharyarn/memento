defmodule Memento.Tests.Table.Definition do
  use Memento.Support.Case
  alias Memento.Table.Definition

  # NOTE:
  # Put tests for `Definition.validate_options!` directly in
  # the test suite for `Memento.Table`, not here.

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

      assert opts[:type] == :bag
      assert opts[:index] == [:id]
      refute opts[:attributes]
    end
  end

  describe "#merge_options" do
    @existing %{
      mnesia: [type: :ordered_set, index: [:id]],
      memento: [autoincrement: true]
    }
    @new [type: :set, autoincrement: false]

    test "does nothing for empty options" do
      assert @existing == Definition.merge_options(@existing, [])
    end

    test "overrides old options when specified" do
      assert %{memento: memento, mnesia: mnesia} = Definition.merge_options(@existing, @new)

      assert Keyword.get(memento, :autoincrement) == false
      assert Keyword.get(mnesia, :type) == :set
      assert Keyword.get(mnesia, :index) == [:id]
    end
  end

  describe "#validate_table!" do
    test "raises error for non memento table modules/terms" do
      assert_raise(Memento.Error, ~r/is not a memento table/i, fn ->
        Definition.validate_table!(SomeRandomModule)
      end)

      assert_raise(Memento.Error, ~r/is not a memento table/i, fn ->
        Definition.validate_table!(1234)
      end)
    end

    test "returns :ok for valid memento tables" do
      defmodule Meta.Simple do
        use Memento.Table, attributes: [:id, :username]
      end

      assert :ok = Definition.validate_table!(Meta.Simple)
    end
  end

  describe "#has_autoincrement?" do
    test "returns true for Memento Tables that have autoincrement" do
      defmodule Meta.AutoIncrementUser do
        use Memento.Table,
          attributes: [:id, :full_name],
          type: :ordered_set,
          autoincrement: true
      end

      assert Definition.has_autoincrement?(Meta.AutoIncrementUser)
    end

    test "returns false for Memento Tables that don't have autoincrement" do
      defmodule Meta.NoAutoIncrementUser do
        use Memento.Table, attributes: [:id, :full_name]
      end

      refute Definition.has_autoincrement?(Meta.NoAutoIncrementUser)
    end
  end
end
