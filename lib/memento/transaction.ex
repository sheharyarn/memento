defmodule Memento.Transaction do
  require Memento.Mnesia


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
  @spec execute(fun, integer) :: any
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
  @spec execute_sync(fun, integer) :: any
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


end
