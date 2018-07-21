defmodule Memento do
  require Memento.Mnesia


  @moduledoc """
  Nothing here now, come back later

  TODO: Convert this into an 'Application'
  """




  # Public API
  # ----------


  @doc """
  Start the Memento Application.

  This starts Memento and `:mnesia` along with some sane application
  defaults. See `:mnesia.start/0` for more details.
  """
  @spec start() :: Memento.Mnesia.result
  def start do
    Application.start(:mnesia)
  end




  @doc """
  Stop the Memento Application.
  """
  @spec stop() :: Memento.Mnesia.result
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


end
