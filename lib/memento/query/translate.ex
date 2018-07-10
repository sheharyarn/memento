defmodule Memento.Query.Translate do
  @moduledoc """
  Helper module to convert Memento queries into Erlang
  match_spec
  """



  # Public API
  # ----------


  @doc """
  Translate a query into erlang match_spec by replacing
  values from previously generated map
  """
  def translate(map, list) when is_list(list) do
    Enum.map(list, &translate(map, &1))
  end

  def translate(map, atom) when is_atom(atom) do
    case map[atom] do
      nil -> atom
      value -> value
    end
  end

  def translate(map, {operation, arg1, arg2}) do
    {
      translate_operation(operation),
      translate(map, arg1),
      translate(map, arg2)
    }
  end

  def translate(_map, term) do
    term
  end




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

  Takes attribute keywords `[a: nil, b: nil, ...]` or
  list, and converts them into `%{a: :$1, b: :$2, ...}`
  """
  def build_map(attributes) do
    attributes
    |> Enum.reduce({%{}, 1}, &build_reducer/2)
    |> elem(0)
  end





  # Private Helpers
  # ---------------


  # Helper function for building translation map.
  # Used in the reduce call inside `build_map`
  defp build_reducer(attr, {map, position}) when is_atom(attr) do
    {
      Map.put(map, attr, :"$#{position}"),
      position + 1
    }
  end

  # TODO: Delete this when Amnesia is removed
  defp build_reducer({attr, nil}, {map, position}) do
    build_reducer(attr, {map, position})
  end


  # Translates Operations into those defined by the
  # Erlang match spec
  defp translate_operation(:or),  do: :orelse
  defp translate_operation(:and), do: :andalso
  defp translate_operation(term), do: term


end
