defmodule Memento.Tests.Transaction do
  use Memento.Support.Case
  alias Memento.Transaction


  # Don't need to extensively rest these methods, just how
  # they return back the data.



  describe "#execute" do
    test "re-raises mnesia rescues as original errors" do
      assert_raise(UndefinedFunctionError, ~r/is undefined/i, fn ->
        Transaction.execute fn ->
          RandomModule.undefined_fun
        end
      end)
    end


    test "function is actually executed inside a transaction" do
      Transaction.execute fn ->
        assert true == :mnesia.is_transaction
      end
    end
  end



  describe "#execute!" do
    test "re-raises mnesia rescues as original errors" do
      assert_raise(UndefinedFunctionError, ~r/is undefined/i, fn ->
        Transaction.execute! fn ->
          RandomModule.undefined_fun
        end
      end)
    end


    test "function is actually executed inside a transaction" do
      Transaction.execute! fn ->
        assert {:atomic, true} == :mnesia.is_transaction
      end
    end
  end


end
