defmodule Memento do
  require Memento.Mnesia


  @moduledoc """
  Simple + Powerful interface to the Erlang Mnesia Database.


  See the [README](https://github.com/sheharyarn/memento) to get
  started.
  """




  # Public API
  # ----------


  @doc """
  Start the Memento Application.

  This starts Memento and `:mnesia` along with some sane application
  defaults. See `:mnesia.start/0` for more details.
  """
  @spec start() :: :ok | {:error, any}
  def start do
    Application.start(:mnesia)
  end




  @doc """
  Stop the Memento Application.
  """
  @spec stop() :: :ok | {:error, any}
  def stop do
    Application.stop(:mnesia)
  end




  @doc """
  Prints `:mnesia` information to console.
  """
  @spec info() :: :ok
  def info do
    Memento.Mnesia.call(:info, [])
  end




  @doc """
  Returns all information about the Mnesia system.

  Optionally accepts a `key` atom argument which returns result for
  only that key. Will throw an exception if that key is invalid. See
  `:mnesia.system_info/0` for more information and a full list of
  allowed keys.
  """
  @spec system(atom) :: any
  def system(key \\ :all) do
    Memento.Mnesia.call(:system_info, [key])
  end



  # Delegates

  defdelegate transaction(fun),   to: Memento.Transaction,  as: :execute
  defdelegate transaction!(fun),  to: Memento.Transaction,  as: :execute!

end
