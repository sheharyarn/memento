defmodule Memento.Tests.Mnesia do
  use Memento.Support.Case

  alias Memento.Mnesia
  alias Memento.MnesiaException
  require Mnesia

  describe "#call" do
    test "delegates method calls to the mnesia module" do
      assert :yes == Mnesia.call(:system_info, [:is_running])
    end
  end

  describe "#call_and_catch" do
    setup do
      Support.Mnesia.stop()
      :ok
    end

    @func :system_info
    @args [:is_running]
    test "delegates method calls to the mnesia module" do
      assert :no == Mnesia.call_and_catch(@func, @args)
    end

    @func :schema
    @args []
    test "re-raises mnesia exits as memento exceptions" do
      assert_raise(MnesiaException, ~r/not running/i, fn ->
        Mnesia.call_and_catch(@func, @args)
      end)
    end

    @func :table_info
    @args [Tables.User, :all]
    test "prints descriptions of the error" do
      assert_raise(MnesiaException, ~r/tried to perform op on non-existing/i, fn ->
        Mnesia.call_and_catch(@func, @args)
      end)
    end
  end

  describe "#handle_result" do
    test "reraises specific erlang errors as elixir exceptions" do
      assert_raise(
        UndefinedFunctionError,
        ~r/is undefined/i,
        result_for(fn ->
          RandomModule.undefined_fun()
        end)
      )
    end

    test "reraises custom elixir errors" do
      assert_raise(
        Memento.Error,
        ~r/hello/i,
        result_for(fn ->
          raise Memento.Error, message: "hello"
        end)
      )
    end

    test "reraises on-the-fly runtime errors" do
      assert_raise(
        RuntimeError,
        ~r/not compiled/i,
        result_for(fn ->
          raise "this error module was not compiled"
        end)
      )
    end

    test "rethrows any throws" do
      catch_throw(result_for(fn -> throw(:fail) end).())
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

  # Private Helper to test `handle_result` errors
  defp result_for(fun) do
    fn ->
      Mnesia.handle_result(:mnesia.transaction(fun))
    end
  end
end
