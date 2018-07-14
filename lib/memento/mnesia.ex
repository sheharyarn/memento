defmodule Memento.Mnesia do
  @moduledoc """
  Helper wrapper module to delegate calls to Erlang's `:mnesia`
  """



  # Public API
  # ----------


  @doc "Call an Mnesia function"
  defmacro call(method, arguments \\ []) do
    quote(bind_quoted: [fun: method, args: arguments]) do
      apply(:mnesia, fun, args)
    end
  end



  @doc "Normalize the response from an :mnesia call"
  def handle_response(nil),                 do: nil
  def handle_response(:ok),                 do: :ok
  def handle_response({:atomic, :ok}),      do: :ok
  def handle_response({:error, reason}),    do: {:error, reason}
  def handle_response({:aborted, reason}),  do: {:error, reason}

end
