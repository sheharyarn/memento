defmodule Memento.Query do
  require Memento.Mnesia
  require Memento.Error

  alias Memento.Query
  alias Memento.Table
  alias Memento.Mnesia


  @moduledoc """
  Module to read/write from Memento Tables.

  This module provides the most important transactional operations
  that can be executed on Memento Tables. Mnesia's "dirty" methods
  are left out on purpose. In almost all circumstances, these
  methods would be enough for interacting with Memento Tables, but
  for very special situations, it is better to directly use the
  API provided by the Erlang `:mnesia` module.


  TODO: mention non-nil keys

  ## Transaction Only

  All the methods exported by this module can only be executed
  within the context of a `Memento.Transaction`. Outside the
  transaction (synchronous or not), these methods will raise an
  error, even though they are ignored in all other examples.

  ```
  # Will raise an error
  Memento.Query.read(Blog.Post, :some_id)

  # Will work fine
  Memento.transaction fn ->
    Memento.Query.read(Blog.Post, :some_id)
  end
  ```


  ## Basic Queries

  ```
  read
  first
  write
  all
  ```


  ## Advanced Queries

  Special cases here are the `match/3` and `select/3` methods,
  which use a superset of Erlang's
  [`match_spec`](http://erlang.org/doc/apps/erts/match_spec.html)
  to make working with them much easier.
  """





  # Type Definitions
  # ----------------


  @typedoc """
  Option Keyword that can be passed to some methods.

  These are all the possible options that can be set in the given
  keyword list, although it mostly depends on the method which
  options it actually uses.

  ## Options

  - `lock`: What kind of lock to acquire on the item in that
  transaction. This is the most common option, that almost all
  methods accept, and usually has some default value depending on
  the method. See `t:lock` for more details.

  - `limit`: The maximum number of items to return in a query.
  This is used only read queries like `match/3` or `select/3`, and
  is of the type `t:non_neg_integer`. Defaults to `nil`, resulting
  in no limit and returning all records.

  - `coerce`: Records in Mnesia are stored in the form of a `tuple`.
  This converts them into simple Memento struct records of type
  `t:Memento.Table.record`. This is equivalent to calling
  `Query.Data.load/1` on the returned records. This option is only
  available to some read methods like `select/3` & `match/3`, and its
  value defaults to `true`.
  """
  @type options :: [
    lock: lock,
    limit: non_neg_integer,
    coerce: boolean,
  ]



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


  ## Example

  ```
  Memento.Query.read(Blog.Post, 1)
  # => %Blog.Post{id: 1, ... }

  Memento.Query.read(Blog.Post, 2, lock: :write)
  # => %Blog.Post{id: 2, ... }

  Memento.Query.read(Blog.Post, :unknown_id)
  # => nil
  ```
  """
  @spec read(Table.name, any, options) :: Table.record | nil
  def read(table, id, opts \\ []) do
    lock = Keyword.get(opts, :lock, :read)
    case Mnesia.call(:read, [table, id, lock]) do
      []           -> nil
      [record | _] -> Query.Data.load(record)
    end
  end




  @doc """
  Writes a Memento record to its Mnesia table.

  Returns `:ok` on success, or aborts the transaction on failure.
  This operatiion acquires a lock of the kind specified, which can
  be either `:write` or `:sticky_write` (defaults to `:write`).
  See `t:lock` and `:mnesia.write/3` for more details.

  The `key` is the important part. For now, this method does not
  automatically generate new `keys`, so this has to be done on the
  client side.

  TODO: Implement some sort of `autogenerate` for write.

  ## Examples

  ```
  Memento.Query.write(%Blog.Post{id: 4, title: "something", ... })
  # => :ok

  Memento.Query.write(%Blog.Author{username: "sye", ... })
  # => :ok
  ```
  """
  @spec write(Table.record, options) :: :ok
  def write(record = %{__struct__: table}, opts \\ []) do
    record = Query.Data.dump(record)
    lock   = Keyword.get(opts, :lock, :write)

    Mnesia.call(:write, [table, record, lock])
  end



  # def all(table, opts \\ [])
  # def first

  @doc """
  Returns all records in a table that match the specified pattern.

  This method takes the name of a `Memento.Table` and a tuple pattern
  representing the values of those attributes, and returns all
  records that match it. It uses `:_` to represent attributes that
  should be ignored. The tuple passed should be of the same length as
  the number of attributes in that table, otherwise it will throw an
  exception.

  It's recommended to use the `select/3` method as it is more
  user-friendly, can let you make complex selections.

  Also accepts an optional argument `:lock` to acquire the kind of
  lock specified in that transaction (defaults to `:read`). See
  `t:lock` for more details. Also see `:mnesia.match_object/3`.

  ## Examples

  Suppose a `Movie` Table with these attributes: `id`, `title`, `year`,
  and `director`. So the tuple passed in the match query should have
  4 elements.

  ```
  # Get all movies from the Table
  Memento.Query.match(Movie, {:_, :_, :_, :_})

  # Get all movies named 'Rush'
  Memento.Query.match(Movie, {:_, "Rush", :_, :_})

  # Get all movies directed by Tarantino
  Memento.Query.match(Movie, {:_, :_, :_, "Quentin Tarantino"})

  # Get all movies directed by Spielberg, in the year 1993
  Memento.Query.match(Movie, {:_, :_, 1993, "Steven Spielberg"})
  ```
  """
  @spec match(Table.name, tuple, options) :: list(Table.record) | no_return
  def match(table, pattern, opts \\ []) when is_tuple(pattern) do
    validate_match_pattern!(table, pattern)
    lock = Keyword.get(opts, :lock, :read)

    # Convert {x, y, z} -> {Table, x, y, z}
    pattern =
      List.to_tuple([ table | Tuple.to_list(pattern) ])

    :match_object
    |> Mnesia.call([table, pattern, lock])
    |> Enum.map(&Query.Data.load/1)
  end

  # # Result is automatically formatted
  # def where(table, pattern, lock: :read, limit: nil, coerce: true)

  # # Result is not casted
  # def select(table, match_spec, lock: :read, limit: nil, coerce: false)

  # def test_matchspec





  # Private Helpers
  # ---------------


  # Raises error if tuple size and no. of attributes is not equal
  defp validate_match_pattern!(table, pattern) do
    same_size? =
      (tuple_size(pattern) == table.__info__.size)

    unless same_size? do
      Memento.Error.raise(
        "Match Pattern length is not equal to the no. of attributes"
      )
    end
  end

end
