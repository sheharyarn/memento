def Memento.Query do
  @moduledoc """
  Module to help build Mnesia Queries
  """


  @doc "Define functions and attributes for making queries"
  defmacro __using__(_opts) do
    quote do
      @query_map    Memento.Query.Translate.build_map(@attributes)
      @query_base   Memento.Query.Translate.build_base(__MODULE__, @attributes)
      @query_result [:"$_"]
    end
  end

end
