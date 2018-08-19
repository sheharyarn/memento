defmodule Memento.Error do
  alias Memento.DoesNotExistError
  alias Memento.AlreadyExistsError
  alias Memento.MnesiaException


  defexception [:message]


  @moduledoc false
  @default_message "Operation Failed"




  # Raise Macros
  # ------------


  # Raise a Memento.Error
  defmacro raise(message \\ @default_message) do
    quote do
      raise Memento.Error, message: unquote(message)
    end
  end


  # Finds the appropriate Memento error from an Mnesia exit
  # Falls back to a default 'MnesiaException'
  defmacro raise_from(data) do
    quote(bind_quoted: [data: data]) do
      raise Memento.Error.normalize(data)
    end
  end




  # Error Builders
  # --------------


  # Helper Method to Build Memento Error
  def normalize({:error,   reason}), do: do_normalize(reason)
  def normalize({:aborted, reason}), do: do_normalize(reason)
  def normalize(reason),             do: do_normalize(reason)


  defp do_normalize(reason) do
    case reason do
      {:no_exists, resource} ->
        %DoesNotExistError{message: "#{inspect(resource)} does not exist or is not alive"}

      {:already_exists, resource} ->
        %AlreadyExistsError{message: "#{inspect(resource)} already exists"}

      # Don't need custom errors for the rest, fallback to MnesiaException
      # and raise with Mnesia's description of the error
      error ->
        MnesiaException.build(error)
    end
  end

end
