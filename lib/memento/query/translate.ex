defmodule Memento.Query.Translate do
  @moduledoc false

  # Helper module to convert Query.select patterns into
  # Erlang match_spec.



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
      rewrite_guard(operation),
      translate(map, arg1),
      translate(map, arg2)
    }
  end

  def translate(_map, term) do
    term
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

end
