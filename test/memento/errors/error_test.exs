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



  describe "#raise_from_code" do
    # Testing just one code here. The rest should also work if all the
    # test cases for #normalize pass, since all this does is raise the
    # error resolved by that
    @mnesia_code :no_transaction
    test "raises the correct memento error from mnesia code" do
      assert_raise(Memento.NoTransactionError, fn ->
        Memento.Error.raise_from_code(@mnesia_code)
      end)
    end
  end



  describe "#normalize" do
    test "resolves to AlreadyExistsError for :already_exists" do
      assert %Memento.AlreadyExistsError{} = Memento.Error.normalize({:already_exists, X})
    end


    test "resolves to DoesNotExistError for :no_exists" do
      assert %Memento.DoesNotExistError{} = Memento.Error.normalize({:no_exists, X})
    end


    test "resolves to NoTransactionError for :no_transaction" do
      assert %Memento.NoTransactionError{} = Memento.Error.normalize(:no_transaction)
    end


    @rest_of_mnesia_errors ~w[
      nested_transaction bad_arg combine_error bad_index index_exists
      system_limit mnesia_down not_a_db_node bad_type node_not_running
      truncated_binary_file active illegal
    ]a
    test "falls back to MnesiaException for other errors" do
      Enum.each(@rest_of_mnesia_errors, fn error ->
        assert %Memento.MnesiaException{} = Memento.Error.normalize({error, X})
      end)
    end
  end

end
