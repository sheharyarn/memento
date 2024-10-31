defmodule Memento.Tests.Schema do
  use Memento.Support.Case

  alias Memento.Table
  alias Memento.Schema
  alias Memento.MnesiaException

  # No need to test all the methods (create/delete)
  # Just one is enough

  describe "#info" do
    @table Tables.User
    @attrs "\\[id,name\\]"
    @pattern "{'#{@table}',\n?.+'_','_'}"

    setup(do: Table.create(@table))

    test "raises error when mnesia is not running" do
      Support.Mnesia.stop()

      assert_raise(MnesiaException, ~r/node not running/i, fn ->
        Schema.info()
      end)
    end

    test "prints full schema information when no argument is provided" do
      output =
        Support.capture_io(fn ->
          Schema.info()
        end)

      assert output =~ ~r/-- properties for schema table --/i
      assert output =~ ~r/wild_pattern .* {schema,'_','_'}/i
      assert output =~ ~r/tables .* ['#{@table}', schema]/i

      assert output =~ ~r/-- properties for '#{@table}' table --/i
      assert output =~ ~r/wild_pattern .* #{@pattern}/i
      assert output =~ ~r/attributes .* #{@attrs}/i
    end

    test "prints specific schema information when a table is specified" do
      output =
        Support.capture_io(fn ->
          Schema.info(@table)
        end)

      refute output =~ ~r/-- properties for schema table --/i
      refute output =~ ~r/wild_pattern .* {schema,'_','_'}/i
      refute output =~ ~r/tables .* ['#{@table}', schema]/i

      assert output =~ ~r/-- properties for '#{@table}' table --/i
      assert output =~ ~r/wild_pattern .* #{@pattern}/i
      assert output =~ ~r/attributes .* #{@attrs}/i
    end
  end
end
