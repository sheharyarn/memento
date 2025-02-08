defmodule Memento.TransactionAborted do
  defexception [:message]

  @moduledoc false


  # Raise a Memento.TransactionAborted
  defmacro raise(reason) do
    quote(bind_quoted: [reason: reason]) do
      raise Memento.TransactionAborted,
        message: "Transaction aborted with: #{inspect(reason)}"
    end
  end

end

