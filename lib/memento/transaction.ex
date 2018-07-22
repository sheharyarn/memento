defmodule Memento.Transaction do
  require Memento.Mnesia
  require Memento.Error


  @moduledoc """
  Memento's wrapper around Mnesia transactions. This module exports
  methods `execute/2` and `execute_sync/2`, which accept a function
  to be executed an and optional argument to set the maximum no. of
  retries until the transaction succeeds.

  Both methods can be directly called on the base `Memento` module
  as `Memento.transaction/2` and `Memento.transaction_sync/2`.

  # TODO: Add delegate in root module
  #
  # TODO: Add examples
  """




  # Public API
  # ----------


  @doc """
  Execute passed function as part of an Mnesia transaction.

  Default value of `retries` is `:infinity`. Returns either
  `{:ok, result}` or `{:error, reason}`. Also see
  `:mnesia.transaction/2`.
  """
  @spec execute(fun, integer) :: {:ok, any} | {:error, any}
  def execute(function, retries \\ :infinity) do
    :transaction
    |> Memento.Mnesia.call([function, retries])
    |> Memento.Mnesia.handle_result
  end




  @doc """
  Execute the transaction in synchronization with all nodes.

  This method waits until the data has been committed and logged to
  disk (if used) on all involved nodes before it finishes. This is
  useful to ensure that a transaction process does not overload the
  databases on other nodes.

  Returns either `{:ok, result}` or `{:error, reason}`. Also see
  `:mnesia.sync_transaction/2`.
  """
  @spec execute_sync(fun, integer) :: {:ok, any} | {:error, any}
  def execute_sync(function, retries \\ :infinity) do
    :sync_transaction
    |> Memento.Mnesia.call([function, retries])
    |> Memento.Mnesia.handle_result
  end




  @doc """
  Checks if you are inside a transaction.
  """
  @spec inside?() :: boolean
  def inside? do
    Memento.Mnesia.call(:is_transaction)
  end




  @doc """
  Aborts a Memento transaction.

  Causes the transaction to return an error tuple with the passed
  argument: `{:error, {:transaction_aborted, reason}}`. Outside
  the context of a transaction, simply raises an error.

  Default value for reason is `:no_reason_given`. Also see
  `:mnesia.abort/1`.
  """
  @spec abort(term) :: no_return
  def abort(reason \\ :no_reason_given) do
    case inside?() do
      true ->
        :mnesia.abort({:transaction_aborted, reason})

      false ->
        Memento.Error.raise("Not inside a Memento Transaction")
    end
  end


end
