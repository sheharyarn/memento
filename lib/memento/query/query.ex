defmodule Memento.Query do
  require Memento.Mnesia

  alias Memento.Query
  alias Memento.Table
  alias Memento.Mnesia


  @moduledoc """
  Module to read/write from Memento Tables.
  """





  # Type Definitions
  # ----------------


  @typedoc """
  Types of locks that can be acquired.

  There are, in total, 3 types of locks that can be aqcuired, but
  some operations don't support all of them. The `write/2` method,
  for example, can only accept `:write` or `:sticky_write` locks.

  Conflicting lock requests are automatically queued if there is
  no risk of deadlock. Otherwise, the transaction must be
  terminated and executed again. Memento does this automatically
  as long as the upper limit of `retries` is not reached in a
  transaction.


  ## Types

  - `:write` locks are exclusive. That means, if one transaction
  acquires a write lock, no other transaction can acquire any
  kind of lock on the same item.

  - `:read` locks can be shared, meaning if one transaction has a
  read lock on an item, other transactions can also acquire a
  read lock on the same item. However, no one else can acquire a
  write lock on that item while the read lock is in effect.

  - `:sticky_write` locks are used for optimizing write lock
  acquisitions, by informing other nodes which node is locked. New
  sticky lock requests from the same node are performed as local
  operations.


  For more details, see `:mnesia.lock/2`.
  """
  @type lock :: :read | :write | :sticky_write





  # Public API
  # ----------


  @doc """
  Finds the Memento record for the given id in the specified table.

  If no record is found, `nil` is returned. You can also pass an
  optional keyword list as the 3rd argument. The only option currently
  supported is `:lock`, which acquires a lock of specified type on the
  operation (defaults to `:read`). See `t:lock` for more details.

  This method works a bit differently from the original `:mnesia.read/3`
  when the table type is `:bag`. Since a bag can have many records
  with the same key, this returns only the first one. If you want to
  fetch all records with the given key, use `match/3` or `select/2`.
  """
  @spec read(Table.name, any, Keyword.t(lock)) :: Table.record | nil
  def read(table, id, opts \\ []) do
    lock = Keyword.get(opts, :lock, :read)
    case Mnesia.call(:read, [table, id, lock]) do
      []           -> nil
      [record | _] -> Query.Data.load(record)
    end
  end



end
