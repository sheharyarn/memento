defmodule Memento.Strategy do
  @moduledoc """
  Module is a behaviour defining startup and unsplit strategies

  `Memento.Strategy` defines how to startup Memento for use under app
  supervision and how to "unsplit" a failing cluster back together.
  The reference implementation on "unsplitting" Mnesia that inspired
  the naming here can be seen at:

  https://github.com/uwiger/unsplit

  Mnesia _needs_ an unsplit strategy because it isn't magically
  able to avoid [CAP theorem](https://en.wikipedia.org/wiki/CAP_theorem)
  problems. The OTP team implemented logic to detect fail conditions
  but left all things recovery as an exercise to the consumer.

  See `Memento.Supervisor` for additional lifecycle details.
  """

  @doc """
  Execute the startup strategy

  Requires caller to provide table names. Optional list of nodes.
  """
  @callback startup([Memento.Table.name()], [node()]) :: :ok | {:error, String.t()}

  @doc """
  Heal a cluster back together

  On success, the result is a restored, fully-operational cluster.
  """
  @callback unsplit([Memento.Table.name()], [node()]) :: :ok | {:error, String.t()}

  @doc """
  Defines the recovery type

  Abstractly, cluster recovery can be performed two ways:
    1. Running nodes figure out the drops and remotely manipulate
    everything back to a healthy state. (:centralized)
    2. Failed nodes figure out they are gone and actively try to
    rejoin back into the healthy part of the cluster. (:decentralized)
  """
  @callback recovery_type :: :centralized | :decentralized
end
