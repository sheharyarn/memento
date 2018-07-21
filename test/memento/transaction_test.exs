defmodule Memento.Tests.Transaction do
  use Memento.Support.Case
  alias Memento.Transaction


  # Don't need to extensively rest these methods, just how
  # they return back the data.



  describe "#execute" do
    test "re-raises mnesia rescues as real errors" do
      assert_raise(UndefinedFunctionError, ~r/is undefined/i, fn ->
        Transaction.execute fn ->
          RandomModule.undefined_fun
        end
      end)
    end


    @term "some result"
    test "the output is returned with :ok outside the transaction" do
      assert {:ok, @term} = Transaction.execute(fn -> @term end)
    end
  end



  describe "#execute_sync" do
    @term "some result"
    test "the output is returned with :ok outside the transaction" do
      assert {:ok, @term} = Transaction.execute_sync(fn -> @term end)
    end


    test "re-raises mnesia rescues as real errors" do
      assert_raise(UndefinedFunctionError, ~r/is undefined/i, fn ->
        Transaction.execute_sync(fn -> RandomModule.undefined_fun end)
      end)
    end
  end



  describe "#inside?" do
    test "returns true when inside a transaction" do
      assert {:atomic, true} = :mnesia.transaction(&Transaction.inside?/0)
      assert {:atomic, true} = :mnesia.sync_transaction(&Transaction.inside?/0)
    end


    test "returns false when outside a transaction" do
      refute Transaction.inside?
    end
  end


end
