defmodule Memento.Query.Spec do
  @moduledoc false

  # Helper module to convert Query.select patterns into
  # Erlang match_spec.



  # Build a MatchSpec query from guards and attribute
  # translation map
  def build(guards, query_map) when is_list(guards) do
    translate(query_map, guards)
  end

  def build(guard, query_map) when is_tuple(guard) do
    build([guard], query_map)
  end




  # Private
  # -------


  # Translates Operations into those defined by the
  # Erlang match spec
  defp rewrite_guard(:or),    do: :orelse
  defp rewrite_guard(:and),   do: :andalso
  defp rewrite_guard(:<=),    do: :"=<"
  defp rewrite_guard(:!=),    do: :"/="
  defp rewrite_guard(:===),   do: :"=:="
  defp rewrite_guard(:!==),   do: :"=/="
  defp rewrite_guard(term),   do: term



  # Translates the guards themselves
  defp translate(map, list) when is_list(list) do
    Enum.map(list, &translate(map, &1))
  end

  defp translate(map, atom) when is_atom(atom) do
    case map[atom] do
      nil -> atom
      value -> value
    end
  end

  defp translate(map, {operation, arg1, arg2}) do
    {
      rewrite_guard(operation),
      translate(map, arg1),
      translate(map, arg2)
    }
  end

  defp translate(_map, term) do
    term
  end


end
