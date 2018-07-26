defmodule Memento.Support do
  alias Memento.Support

  @moduledoc "Helper functions for tests"


  # Capture Helpers
  defdelegate capture_io(fun),   to: ExUnit.CaptureIO
  defdelegate capture_log(fun),  to: ExUnit.CaptureLog


  defmodule Mnesia do
    @moduledoc "Mnesia-related helpers"


    def reset do
      stop()
      :mnesia.delete_schema([node()])
      start()
    end


    def start, do: Support.capture_log(fn -> Application.start(:mnesia) end)
    def stop,  do: Support.capture_log(fn -> Application.stop(:mnesia) end)


    def transaction!(term) do
      case transaction(term) do
        :ok ->
          nil

        {:ok, something} ->
          something

        {:error, reason} ->
          raise "Failed with: #{inspect(reason)}"

        term ->
          raise "Failed with: #{inspect(term)}"
      end
    end


    def transaction({module, method, args})
    when is_atom(module) and is_atom(method) do
      transaction(fn ->
        apply(module, method, args)
      end)
    end

    def transaction({method, args}) when is_atom(method) do
      require Memento.Mnesia
      transaction(fn ->
        Memento.Mnesia.call(method, args)
      end)
    end


    def transaction(fun) when is_function(fun) do
      Memento.Transaction.execute(fun)
    end


    def select_raw(table, match_spec, opts \\ []) do
      transaction fn ->
        Memento.Query.select_raw(table, match_spec, opts)
      end
    end

  end
end
