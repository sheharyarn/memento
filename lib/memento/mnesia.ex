defmodule Memento.Mnesia do
  @moduledoc false

  # Helper module to delegate calls to Erlang's `:mnesia`
  # via a macro, handle the result including re-raising
  # any errors that have been caught.




  # Public API
  # ----------


  @doc "Call an Mnesia function"
  defmacro call(method, arguments \\ []) do
    quote(bind_quoted: [fun: method, args: arguments]) do
      require Memento.Error

      try do
        apply(:mnesia, fun, args)
      catch
        :exit, error -> Memento.Error.raise_from_code(error)
      end

    end
  end




  @doc "Normalize the result of an :mnesia call"
  @spec handle_result(any) :: any
  def handle_result(result) do
    case result do
      :ok ->
        :ok

      {:atomic, :ok} ->
        :ok

      {:atomic, term} ->
        {:ok, term}

      {:error, reason} ->
        {:error, reason}

      {:aborted, reason = {exception, data}} ->
        reraise_if_valid!(exception, data)
        {:error, reason}

      {:aborted, reason} ->
        {:error, reason}
    end
  end





  # Private Helpers
  # ---------------


  # Check if the error is actually an exception, and reraise it
  defp reraise_if_valid!(:throw, data), do: throw(data)
  defp reraise_if_valid!(exception, stacktrace) do
    error = Exception.normalize(:error, exception, stacktrace)

    case error do
      # Don't do anything if it's an 'original' ErlangError
      %ErlangError{original: ^exception} ->
        nil

      # Raise if it's an actual exception
      %{__exception__: true} ->
        reraise(error, stacktrace)

      # Do nothing if no conditions are met
      _ ->
        nil
    end
  end


end
