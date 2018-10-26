defmodule Memento.Schema do
  require Memento.Mnesia


  @moduledoc """
  Module to interact with the database schema.

  For persisting data, Mnesia databases need to be created on disk. This
  module provides an interface to create the database on the disk of the
  specified nodes. Most of the time that is usually the node that the
  application is running on.

  ```
  # Create schema on current node
  Memento.Schema.create([ node() ]

  # Create schema on many nodes
  node_list = [node(), :alice@host_x, :bob@host_y, :eve@host_z]
  Memento.Schema.create(node_list)
  ```

  Important thing to note here is that only the nodes where data has to
  be persisted to disk have to be included. RAM-only nodes should be
  left out. Disk schemas can also be deleted by calling `delete/1` and
  you can get information about them by calling `info/0`.


  ## Example

  ```elixir
  # The nodes where you want to persist
  nodes = [ node() ]

  # Create the schema
  Memento.stop
  Memento.Schema.create(nodes)
  Memento.start

  # Create disc copies of your tables
  Memento.Table.create!(TableA, disc_copies: nodes)
  Memento.Table.create!(TableB, disc_copies: nodes)
  ```

  """




  # Public API
  # ----------


  @doc """
  Creates a new database on disk on the specified nodes.

  Calling `:mnesia.create_schema` for a custom path throws an exception
  if that path does not exist. Memento's version avoids this by ensuring
  that the directory exists.

  Also see `:mnesia.create_schema/1`.
  """
  @spec create(list(node)) :: :ok | {:error, any}
  def create(nodes) do
    if path = Application.get_env(:mnesia, :dir) do
      :ok = File.mkdir_p!(path)
    end

    :create_schema
    |> Memento.Mnesia.call([nodes])
    |> Memento.Mnesia.handle_result
  end




  @doc """
  Deletes the database previously created by `create/1` on the specified
  nodes.

  Use this with caution, as it makes persisting data obsolete. Also see
  `:mnesia.delete_schema/1`.
  """
  @spec delete(list(node)) :: :ok | {:error, any}
  def delete(nodes) do
    :delete_schema
    |> Memento.Mnesia.call([nodes])
    |> Memento.Mnesia.handle_result
  end




  @doc """
  Prints schema information about all Tables to the console.
  """
  @spec info() :: :ok
  def info do
    :schema
    |> Memento.Mnesia.call
    |> Memento.Mnesia.handle_result
  end




  @doc """
  Prints schema information about the specified Table to the console.
  """
  @spec info(Memento.Table.name) :: :ok
  def info(table) do
    :schema
    |> Memento.Mnesia.call([table])
    |> Memento.Mnesia.handle_result
  end

end
