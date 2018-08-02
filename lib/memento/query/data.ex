defmodule Memento.Query.Data do
  @moduledoc """
  Helper module that acts as an interface to convert Memento Table
  data structs into Mnesia data tuples and vice versa.

  This is responsible for automatically handling conversions
  between data in methods defined in the Query module, so you
  won't need to use this at all.


  ## Usage

  Given a Memento Table:

  ```
  defmodule MyApp.User do
    use Memento.Table, attributes: [:id, :name]
  end
  ```

  You can convert its structs to Mnesia format:

  ```
  Memento.Query.Data.dump(%MyApp.User{id: 1, name: "Sye"})
  # => {MyApp.User, 1, "Sye"}
  ```

  Or convert it back to a struct:

  ```
  Memento.Query.Data.load({MyApp.User, 2, "Rick"})
  # => %MyApp.User{id: 2, name: "Rick"}
  ```
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
  @spec load(tuple) :: Memento.Table.record
  def load(data) when is_tuple(data) do
    [table | values] =
      Tuple.to_list(data)

    values =
      table.__info__()
      |> Map.get(:attributes)
      |> Enum.zip(values)

    struct(table, values)
  end




  @doc """
  Convert Memento Table struct into Mnesia data tuple.

  Use this method when writing data to an Mnesia database. The
  argument should be a struct of a previously defined Memento
  table definition, and this will convert it into a tuple
  representing an Mnesia record.
  """
  @spec dump(Memento.Table.record) :: tuple
  def dump(data = %{__struct__: table}) do
    values =
      table.__info__()
      |> Map.get(:attributes)
      |> Enum.map(&Map.get(data, &1))

    List.to_tuple([ table | values ])
  end


end
