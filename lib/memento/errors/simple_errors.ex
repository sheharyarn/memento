## Simple Error Modules
## --------------------


simple_errors = [
  Memento.DoesNotExistError,
  Memento.AlreadyExistsError,
]

Enum.each(simple_errors, fn error ->
  defmodule error do
    defexception [:message]
  end
end)

