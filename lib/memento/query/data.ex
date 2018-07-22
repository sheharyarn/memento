defmodule Memento.Query.Data do
  @moduledoc """
  This module acts as an interface to convert Memento Table data
  structs into Mnesia data tuples and vice versa.
  """


  @doc """
  Automatically cast Mnesia data into Memento Table struct.
  """
  @spec cast(tuple) :: Memento.Table.data
  def cast(data) when is_tuple(data) do
    [table | values] =
      Tuple.to_list(data)

    values =
      table.__info__()
      |> Map.get(:attributes)
      |> Enum.zip(values)

    struct(table, values)
  end

end
