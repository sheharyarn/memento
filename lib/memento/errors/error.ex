defmodule Memento.Error do
  alias Memento.InvalidOperationError
  alias Memento.NoTransactionError
  alias Memento.AlreadyExistsError
  alias Memento.DoesNotExistError
  alias Memento.MnesiaException


  defexception [:message]


  @moduledoc false
  @default_message "Operation Failed"



  # This guard passes errors tuples of these formats:
  #  - {:error, {type, ...}}
  #  - {:error, {type, :b, :c}}
  #
  # Everything else, including other error tuples will fail this guard
  defguardp is_error_reason(reason, type) when is_tuple(reason) and elem(reason, 0) == type
  defguard is_error(error, type) when is_tuple(error) and elem(error, 0) == :error and is_error_reason(elem(error, 1), type)




  # Macros to Raise Errors
  # ----------------------


  # Raise a Memento.Error
  defmacro raise(message \\ @default_message) do
    quote do
      raise Memento.Error, message: unquote(message)
    end
  end


  # Finds the appropriate Memento error from an Mnesia exit
  # Falls back to a default 'MnesiaException'
  defmacro raise_from_code(data) do
    quote(bind_quoted: [data: data]) do
      raise Memento.Error.normalize(data)
    end
  end




  # Error Builders
  # --------------


  # Helper Method to Build Memento Exceptions
  def normalize({:error,   reason}), do: do_normalize(reason)
  def normalize({:aborted, reason}), do: do_normalize(reason)
  def normalize(reason),             do: do_normalize(reason)


  defp do_normalize(reason) do
    case reason do
      # Mnesia Error Codes
      :no_transaction ->
        %NoTransactionError{message: "Not inside a Memento Transaction"}

      {:no_exists, resource} ->
        %DoesNotExistError{message: "#{inspect(resource)} does not exist or is not alive"}

      {:already_exists, resource} ->
        %AlreadyExistsError{message: "#{inspect(resource)} already exists"}


      # Custom Error Code - Not Part of Mnesia
      {:autoincrement, message} ->
        %InvalidOperationError{message: "Autoincrement #{message}"}


      # Don't need custom errors for the rest, fallback to MnesiaException
      # and raise with Mnesia's description of the error
      error ->
        MnesiaException.build(error)
    end
  end

end
