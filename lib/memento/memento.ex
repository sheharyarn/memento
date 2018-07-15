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
    Memento.Mnesia.suppress_log fn ->
      Application.stop(:mnesia)
    end
  end


end
