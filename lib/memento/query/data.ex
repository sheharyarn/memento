defmodule Memento.Query.Data do
  @moduledoc """
  Helper module that acts as an interface to convert Memento Table
  data structs into Mnesia data tuples and vice versa.

  This is responsible for automatically handling conversions
  between data in methods defined in the Query module, so you
  won't need to use this at all.
  """



  # Public API
  # ----------


  @doc """
  Convert Mnesia data tuple into Memento Table struct.

  Use this method when reading data from an Mnesia database. The
  data should be in a tuple format, where the first element is
  the Table name (`Memento.Table` definition).

  This will automatically match the the tuple values against the
  table's attributes and convert it into a struct of the Memento
  table you defined.
  """
  @spec load(tuple) :: Memento.Table.data
  def load(data) when is_tuple(data) do
    [table | values] =
      Tuple.to_list(data)

    values =
      table.__info__()
      |> Map.get(:attributes)
      |> Enum.zip(values)

    struct(table, values)
  end


end
