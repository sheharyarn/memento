defmodule Memento.Strategy.Startup do
  @moduledoc """
  Module is a behaviour defining supervised startup strategy

  `Memento.Strategy.Startup` defines how to startup Memento
  under supervision. See `Memento.Supervisor` for additional
  details.
  """

  @doc """
  Execute the startup strategy

  Requires caller to provide table names. Optional list of nodes.
  """
  @callback execute([Memento.Table.name()], [node()]) :: :ok | {:error, String.t()}
end
