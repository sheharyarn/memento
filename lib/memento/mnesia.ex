defmodule Memento.Mnesia do
  @moduledoc """
  Helper wrapper module to delegate calls to Erlang's `:mnesia`
  """



  # Public API
  # ----------


  @doc "Call an Mnesia function"
  defmacro call(method, arguments \\ []) when is_atom(method) do
    quote(bind_quoted: [fun: method, args: arguments]) do
      apply(:mnesia, fun, args)
    end
  end



  @doc "Handle a response from an :mnesia call"
  def normalize(nil),                 do: nil
  def normalize(:ok),                 do: :ok
  def normalize({:atomic, :ok}),      do: :ok
  def normalize({:error, reason}),    do: {:error, reason}
  def normalize({:aborted, reason}),  do: {:error, reason}

end
