def Memento.Query.Translate do
  @moduledoc """
  Helper module to convert Memento queries into Erlang
  match_spec
  """




  # Public API
  # ----------



  @doc """
  Builds the base of the `match_spec`, to be later used
  in `select` calls. Should ideally be called once
  during compile-time.

  Takes attribute keywords or list `[:a, :b, :c, ...]`
  and converts them into `{module, :$1, :$2, ...}`
  """
  def build_base(module, attributes) do
    attributes =
      attributes
      |> Enum.count
      |> Range.new(1)
      |> Enum.reverse
      |> Enum.map(&:"$#{&1}")

    List.to_tuple([ module | attributes ])
  end




  @doc """
  Builds a map with attributes and their corresponding
  keys, to later help with quickly replacing attributes
  with their ids. Should ideally be called once during
  compile-time.

  Takes attribute keywords `[a: nil, b: nil, ...]` them
  into `%{a: :$1, b: :$2, ...}`
  """
  def build_map(attributes) do
    attributes
    |> Enum.reduce({%{}, 1}, &translator/2)
    |> elem(0)
  end





  # Private Helpers
  # ---------------


  # Helper function for building translation map.
  # Used in the reduce call inside `build_map`
  defp translator({attr, nil}, {map, position}) do
    {
      Map.put(map, attr, :"$#{position}"),
      position + 1
    }
  end


end
