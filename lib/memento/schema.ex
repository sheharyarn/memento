defmodule Memento.Schema do
  require Memento.Mnesia


  @moduledoc """
  Module to interact with the schema database.

  For persisting data, Mnesia databases need to be created on disk. This
  module provides an interface to create the database on the disk of the
  specified nodes. Most of the time that is usually the node that the
  application is running on.

  ```
  # Create disk copies on current node
  Memento.Schema.create([ node() ]

  # Create disk copies on many nodes
  node_list = [node(), :bob@machine_x, :alice@machine_y, :eve@machine_z]
  Memento.Schema.create(node_list)
  ```

  Important thing to note here is that only the nodes where data has to
  be persisted to disk have to be included. RAM-only nodes should be
  left out. Disk schemas can also be deleted by calling `delete/1` and
  you can get information about them by calling `info/0`.
  """


end
