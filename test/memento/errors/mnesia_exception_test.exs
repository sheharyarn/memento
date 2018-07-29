defmodule Memento.Tests.Error.MnesiaException do
  use Memento.Support.Case, async: true

  alias Memento.MnesiaException
  require MnesiaException


  describe "#raise" do
    @error :hello
    @message ":hello"

    test "prints standard error message" do
      assert_raise(MnesiaException, ~r/mnesia operation failed/i, fn ->
        MnesiaException.raise(@error)
      end)
    end

    test "throws an exception with data" do
      assert_raise(MnesiaException, ~r/#{@message}/i, fn ->
        MnesiaException.raise(@error)
      end)
    end


    test "parses the underlying message in error tuples" do
      error_tuple = {:error, {:some, :message}}
      error_message = "{:some, :message}"

      assert_raise(MnesiaException, ~r/#{error_message}/, fn ->
        MnesiaException.raise(error_tuple)
      end)

      aborted_tuple = {:aborted, {:another, :message}}
      aborted_message = "{:another, :message}"

      assert_raise(MnesiaException, ~r/#{aborted_message}/, fn ->
        MnesiaException.raise(aborted_tuple)
      end)
    end
  end

end

