defmodule Memento.Mnesia do
  @moduledoc """
  Helper wrapper module to delegate calls to Erlang's `:mnesia`
  """


  # Type Definitions
  # ----------------

  @typedoc "Normalized response of an Mnesia call"
  @type result :: :ok | {:error, any}




  # Public API
  # ----------


  @doc "Call an Mnesia function"
  defmacro call(method, arguments \\ []) do
    quote(bind_quoted: [fun: method, args: arguments]) do
      apply(:mnesia, fun, args)
    end
  end



  @doc "Normalize the result of an :mnesia call"
  @spec handle_result(any) :: result
  def handle_result(:ok),                 do: :ok
  def handle_result({:atomic, :ok}),      do: :ok
  def handle_result({:error, reason}),    do: {:error, reason}
  def handle_result({:aborted, reason}),  do: {:error, reason}


end
