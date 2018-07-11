defmodule Memento.Error do
  defexception [:message]

  @moduledoc false
  @default_message "Operation Failed"


  # Raise a Memento.Error
  defmacro raise(message \\ @default_message) do
    quote do
      raise Memento.Error, message: unquote(message)
    end
  end

end
