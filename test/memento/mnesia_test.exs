defmodule Memento.Tests.Mnesia do
  use Memento.Support.Case

  alias Memento.Mnesia
  alias Memento.MnesiaException
  require Mnesia


  describe "#call" do
    setup do
      Support.Mnesia.stop
      :ok
    end


    @func :system_info
    @args [:is_running]
    test "delegates method calls to the mnesia module" do
      assert :no == Mnesia.call(@func, @args)
    end


    @func :schema
    @args []
    test "re-raises mnesia exits as memento exceptions" do
      assert_raise(MnesiaException, ~r/not running/i, fn ->
        Mnesia.call(@func, @args)
      end)
    end


    @func :table_info
    @args [Tables.User, :all]
    test "prints descriptions of the error" do
      assert_raise(MnesiaException, ~r/tried to perform op on non-existing/i, fn ->
        Mnesia.call(@func, @args)
      end)
    end

  end
end
