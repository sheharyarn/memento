defmodule Memento.Tests.TransactionAborted do
  use Memento.Support.Case, async: true
  require Memento.TransactionAborted

  describe "#raise" do
    @reason :something_went_wrong
    test "raises error with the given reason" do
      expected_reason = ~r/transaction aborted .* #{inspect(@reason)}/i

      assert_raise(Memento.TransactionAborted, expected_reason, fn ->
        Memento.TransactionAborted.raise(@reason)
      end)
    end
  end
end
