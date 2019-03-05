defmodule Memento.Mnesia do
  @moduledoc false

  # Helper module to delegate calls to Erlang's `:mnesia`
  # via a macro, handle the result including re-raising
  # any errors that have been caught.




  # Helper API
  # ----------


  @doc "Call an Mnesia function"
  defmacro call(method, arguments \\ []) do
    quote(bind_quoted: [fun: method, args: arguments]) do
      apply(:mnesia, fun, args)
    end
  end



  @doc """
  Call an Mnesia function and catch any exits

  Should ONLY be used with transaction methods, because catching
  exits inside transactions seriously impacts the performance of
  Mnesia.

  Reference: https://github.com/sheharyarn/memento/issues/2
  """
  defmacro call_and_catch(method, arguments \\ []) do
    quote(bind_quoted: [fun: method, args: arguments]) do
      require Memento.Error

      try do
        apply(:mnesia, fun, args)
      catch
        :exit, error -> Memento.Error.raise_from_code(error)
      end

    end
  end




  @doc """
  Normalize the result of an :mnesia call

  Mnesia transactions even rescue serious errors and return the
  underlying error code and stacktrace. That does not seem
  right, because if an error is raised by some method inside a
  transaction, it should be handled/rescued directly inside that
  scope.

  This will check if an exception was rescued inside the mnesia
  transaction and will re-raise it (even if the non-bang versions
  of the Memento transaction methods are used).
  """
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
