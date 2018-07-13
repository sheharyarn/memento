defmodule Memento.Query do
  @moduledoc """
  Module to help build Mnesia Queries
  """



  # Public API
  # ----------


  @doc "Define functions and attributes for making queries"
  defmacro __using__(_opts) do
    quote do
      @query_map    Memento.Table.Definition.build_map(@attributes)
      @query_base   Memento.Table.Definition.build_base(__MODULE__, @attributes)
      @query_result [:"$_"]


      def query(pattern) do
        Amnesia.transaction(do: Memento.Query.query(pattern))
      end

    end
  end



  @doc "Run a Query"
  defmacro query(pattern) do
    quote do
      query = Memento.Query.build(@query_map, unquote(pattern))

      [{ @query_base, query, @query_result }]
      |> __MODULE__.select
      |> Amnesia.Selection.coerce(__MODULE__)
      |> Amnesia.Selection.values
    end
  end



  @doc "Build a query"
  def build(query_map, pattern) when is_list(pattern) do
    Memento.Query.Translate.translate(query_map, pattern)
  end

  def build(query_map, pattern) when is_tuple(pattern) do
    build(query_map, [pattern])
  end

end
