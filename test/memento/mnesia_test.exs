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



  describe "#handle_result" do
    test "reraises erlang errors as exceptions" do
      assert_raise(UndefinedFunctionError, ~r/is undefined/i, fn ->
        (fn -> RandomModule.undefined_fun end)
        |> :mnesia.transaction
        |> Mnesia.handle_result
      end)
    end


    test "simply returns :error for aborted transactions instead of raising them" do
      reason = "HELLO!!"
      result = {:aborted, {:transaction_aborted, reason}}

      assert {:error, {:transaction_aborted, ^reason}} = Mnesia.handle_result(result)
    end


    test "converts :atomic results into :ok results" do
      assert :ok = Mnesia.handle_result(:ok)
      assert :ok = Mnesia.handle_result({:atomic, :ok})
      assert {:ok, "TERM"} = Mnesia.handle_result({:atomic, "TERM"})
    end


    test "converts :aborted results into :error results" do
      assert {:error, "some_reason"} = Mnesia.handle_result({:aborted, "some_reason"})
    end
  end


end
