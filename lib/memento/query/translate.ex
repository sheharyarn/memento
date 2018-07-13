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




  # Private Helpers
  # ---------------


  # Translates Operations into those defined by the
  # Erlang match spec
  defp translate_operation(:or),  do: :orelse
  defp translate_operation(:and), do: :andalso
  defp translate_operation(term), do: term

end
