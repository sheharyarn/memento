defmodule Memento.Tests.Error do
  use Memento.Support.Case, async: true
  require Memento.Error


  describe "#raise" do
    test "raises error with default message" do
      assert_raise(Memento.Error, "Operation Failed", fn ->
        Memento.Error.raise
      end)
    end


    @message "Something Happened"
    test "raises error with given message" do
      assert_raise(Memento.Error, @message, fn ->
        Memento.Error.raise(@message)
      end)
    end
  end

end
