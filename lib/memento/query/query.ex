defmodule Memento.Query do
  require Memento.Mnesia
  require Memento.Error

  alias Memento.Query
  alias Memento.Mnesia
  alias Memento.Table
  alias Memento.Table.Definition


  @moduledoc """
  Module to read/write from Memento Tables.

  This module provides the most important transactional operations
  that can be executed on Memento Tables. Mnesia's "dirty" methods
  are left out on purpose. In almost all circumstances, these
  methods would be enough for interacting with Memento Tables, but
  for very special situations, it is better to directly use the
  API provided by the Erlang `:mnesia` module.


  ## Transaction Only

  All the methods exported by this module can only be executed
  within the context of a `Memento.Transaction`. Outside the
  transaction (synchronous or not), these methods will raise an
  error, even though they will be ignored in all examples moving
  forward.

  ```
  # Will raise an error
  Memento.Query.read(Blog.Post, :some_id)

  # Will work fine
  Memento.transaction fn ->
    Memento.Query.read(Blog.Post, :some_id)
  end
  ```


  ## Basic Operations

  ```
  # Get all records in a Table
  Memento.Query.all(User)

  # Get a specific record by its primary key
  Memento.Query.read(User, id)

  # Write a record
  Memento.Query.write(%User{id: 3, name: "Some User"})

  # Delete a record by primary key
  Memento.Query.delete(User, id)

  # Delete a record by passing the full object
  Memento.Query.delete_record(%User{id: 4, name: "Another User"})
  ```


  ## Complex Queries

  Memento provides 3 ways of querying records based on some passed
  conditions:

  - `match/3`
  - `select/3`
  - `select_raw/3`

  Each method uses a different way of querying records, which is
  explained in detail for each of them in their method docs. But
  the recommended method of performing queries is using the
  `select/3` method, which makes working with Erlang MatchSpec a
  lot easier.

  ```
  # Get all Movies
  Memento.Query.select(Movie, [])

  # Get all Movies named "Rush"
  Memento.Query.select(Movie, {:==, :title, "Rush"})

  # Get all Movies directed by Tarantino before the year 2000
  guards = [
    {:==, :director, "Quentin Tarantino"},
    {:<, :year, 2000},
  ]
  Memento.Query.select(Movie, guards)
  ```
  """





  # Type Definitions
  # ----------------


  @typedoc """
  Option Keyword that can be passed to some methods.

  These are all the possible options that can be set in the given
  keyword list, although it mostly depends on the method which
  options it actually uses.

  ## Options

  - `lock` - What kind of lock to acquire on the item in that
  transaction. This is the most common option, that almost all
  methods accept, and usually has some default value depending on
  the method. See `t:lock/0` for more details.

  - `limit` - The maximum number of items to return in a query.
  This is used only read queries like `match/3` or `select/3`, and
  is of the type `t:non_neg_integer/0`. Defaults to `nil`, resulting
  in no limit and returning all records.

  - `coerce` - Records in Mnesia are stored in the form of a Tuple.
  This converts them into simple Memento struct records of type
  `t:Memento.Table.record/0`. This is equivalent to calling
  `Memento.Query.Data.load/1` on the returned records. This option is
  only available to some read methods like `select/3` & `match/3`,
  and its value defaults to `true`.
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
  operation (defaults to `:read`). See `t:lock/0` for more details.

  This method works a bit differently from the original `:mnesia.read/3`
  when the table type is `:bag`. Since a bag can have many records
  with the same key, this returns only the first one. If you want to
  fetch all records with the given key, use `match/3` or `select/3`.


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

  Returns the written record on success, or aborts the transaction
  on failure. This operatiion acquires a lock of the kind specified,
  which can be either `:write` or `:sticky_write` (defaults to
  `:write`). See `t:lock/0` and `:mnesia.write/3` for more details.


  ## Autoincrement and `nil` primary keys

  This method will raise an error if the primary key of the passed
  Memento record is `nil` and the table does not have autoincrement
  enabled. If it is enabled, this will find the last numeric key
  used, increment it and assign it as the primary key of the written
  record (which will be returned as a result of the write operation).

  To enable autoincrement, the table needs to be of the type
  `ordered_set` and `autoincrement: true` has to be specified in
  the table definition. (See `Memento.Table` for more details).


  ## Examples

  ```
  Memento.Query.write(%Blog.Post{title: "something", ... })
  # => %Blog.Post{id: 4, title: "something"}

  Memento.Query.write(%Blog.Author{username: "sye", ... })
  # => %Blog.Author{username: "sye", ... }
  ```
  """
  @spec write(Table.record, options) :: Table.record | no_return
  def write(record = %{__struct__: table}, opts \\ []) do
    struct = prepare_record_for_write!(table, record)
    tuple  = Query.Data.dump(struct)
    lock   = Keyword.get(opts, :lock, :write)

    case Mnesia.call(:write, [table, tuple, lock]) do
      :ok  -> struct
      term -> term
    end
  end




  @doc """
  Returns all records of a Table.

  This is equivalent to calling `match/3` with the catch-all pattern.
  This also accepts an optional `lock` option to acquire that kind of
  lock in the transaction (defaults to `:read`). See `t:lock/0` for
  more details about lock types.

  ```
  # Both are equivalent
  Memento.Query.all(Movie)
  Memento.Query.match(Movie, {:_, :_, :_, :_})
  ```
  """
  @spec all(Table.name, options) :: list(Table.record)
  def all(table, opts \\ []) do
    pattern = table.__info__().query_base
    lock = Keyword.get(opts, :lock, :read)

    :match_object
    |> Mnesia.call([table, pattern, lock])
    |> coerce_records
  end




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
  `t:lock/0` for more details. Also see `:mnesia.match_object/3`.

  ## Examples

  Suppose a `Movie` Table with these attributes: `id`, `title`, `year`,
  and `director`. So the tuple passed in the match query should have
  4 elements.

  ```
  # Get all movies from the Table
  Memento.Query.match(Movie, {:_, :_, :_, :_})

  # Get all movies named 'Rush', with a write lock on the item
  Memento.Query.match(Movie, {:_, "Rush", :_, :_}, lock: :write)

  # Get all movies directed by Tarantino
  Memento.Query.match(Movie, {:_, :_, :_, "Quentin Tarantino"})

  # Get all movies directed by Spielberg, in the year 1993
  Memento.Query.match(Movie, {:_, :_, 1993, "Steven Spielberg"})

  # Will raise exceptions
  Memento.Query.match(Movie, {:_, :_})
  Memento.Query.match(Movie, {:_, :_, :_})
  Memento.Query.match(Movie, {:_, :_, :_, :_, :_})
  ```
  """
  @spec match(Table.name, tuple, options) :: list(Table.record) | no_return
  def match(table, pattern, opts \\ []) when is_tuple(pattern) do
    validate_match_pattern!(table, pattern)
    lock = Keyword.get(opts, :lock, :read)

    # Convert {x, y, z} -> {Table, x, y, z}
    pattern =
      Tuple.insert_at(pattern, 0, table)

    :match_object
    |> Mnesia.call([table, pattern, lock])
    |> coerce_records
  end




  @doc """
  Return all records matching the given query.

  This method takes a table name, and a simplified version of the Erlang
  MatchSpec consisting of one or more `guards`. Each guard is of the
  form `{function, argument_1, argument_2}`, where the arguments can be
  the Table fields, literals or other nested guard functions.


  ## Guard Spec

  Simple Operator Functions:

  - `:==` - Equality
  - `:===` - Strict Equality (For Numbers)
  - `:!=` - Inequality
  - `:!==` - Strict Inequality (For Numbers)
  - `:<` - Less than
  - `:<=` - Less than or equal to
  - `:>` - Greater than
  - `:>=` - Greater than or equal to

  Guard Functions that take nested arguments:

  - `:or`
  - `:and`
  - `:xor`


  ## Options

  This method also takes some optional arguments mentioned below. See
  `t:options/0` for more details.

  - `lock` (defaults to `:read`)
  - `limit` (defaults to `nil`, meaning return all)
  - `coerce` (defaults to `true`)


  ## Examples

  Suppose a `Movie` Table with these attributes: `id`, `title`, `year`,
  and `director`.

  ```
  # Get all Movies
  Memento.Query.select(Movie, [])

  # Get all Movies named "Rush"
  Memento.Query.select(Movie, {:==, :title, "Rush"})

  # Get all Movies directed by Tarantino before the year 2000
  # Note: We could use a nested `and` function here as well
  guards = [
    {:==, :director, "Quentin Tarantino"},
    {:<, :year, 2000},
  ]
  Memento.Query.select(Movie, guards)

  # Get all movies directed by Tarantino or Spielberg, in 2010 or later:
  guards =
    {:and
      {:>=, :year, 2010},
      {:or,
        {:==, :director, "Quentin Tarantino"},
        {:==, :director, "Steven Spielberg"},
      }
    }
  Memento.Query.select(Movie, guards)
  ```
  """
  @result [:"$_"]
  @spec select(Table.name, list(tuple) | tuple, options) :: list(Table.record)
  def select(table, guards, opts \\ []) do
    info = table.__info__()

    attr_map   = info.query_map
    match_head = info.query_base
    guards     = Memento.Query.Spec.build(guards, attr_map)

    select_raw(table, [{ match_head, guards, @result }], opts)
  end




  @doc """
  Returns all records in the given table according to the full Erlang
  `match_spec`.

  This method accepts a pure Erlang `match_spec` term as described below,
  which can be used to write some very complex queries, but that also
  makes it very hard to use for beginners, and overly complex for everyday
  queries. It is highly recommended that you use the `select/3` method
  which makes it much easier to write complex queries that work just as
  well in 99% of the cases, by making some assumptions.

  The arguments are directly passed on to the `:mnesia.select/4` method
  without translating queries, as they are done in `select/3`.


  ## Options

  See `t:options/0` for details about these options:

  - `lock` (defaults to `:read`)
  - `limit` (defaults to `nil`, meaning return all)
  - `coerce` (defaults to `true`)


  ## Match Spec

  An Erlang "Match Specification" or `match_spec` is a term describing
  a small program that tries to match something. This is most popularly
  used in both `:ets` and `:mnesia`. Quite simply, the grammar can be
  defined as:

  - `match_spec` = `[match_function, ...]` (List of match functions)
  - `match_function` = `{match_head, [guard, ...], [result]}`
  - `match_head` = `tuple` (A tuple representing attributes to match)
  - `guard` = A tuple representing conditions for selection
  - `result` = Atom describing the fields to return as the result

  Here, the `match_head` describes the attributes to match (like in
  `match/3`). You can use literals to specify an exact value to be
  matched against or `:"$n"` variables (`:$1`, `:$2`, ...)  that can be
  used so they can be referenced in the guards. You can get a default
  value by calling `YourTable.__info__().query_base`.

  The second element in the tuple is a list of `guard` terms, where each
  guard is basically a tuple representing a condition of the form
  `{operation, arg1, arg2}` which can be simple `{:==, :"$2", literal}`
  tuples or nested values like `{:andalso, guard1, guard2}`. Finally,
  `result` represents the fields to return. Use `:"$_"` to return all
  fields, `:"$n"` to return a specific field or `:"$$"` for all fields
  specified as variables in the `match_head`.


  ## Examples

  Suppose a `Movie` Table with these attributes: `id`, `title`, `year`,
  and `director`. So the tuple passed as the match_head should have
  5 elements.

  Return all records:

  ```
  match_head = Movie.__info__().query_base
  result = [:"$_"]
  guards = []

  Memento.Query.select_raw(Movie, [{match_head, guards, result}])
  # => [%Movie{...}, ...]
  ```

  Get all movies with the title "Rush":

  ```
  # We're using the match_head pattern here, but you can also use guards
  match_head = {Movie, :"$1", "Rush", :"$2", :"$3"}
  result = [:"$_"]
  guards = []

  Memento.Query.select_raw(Movie, [{match_head, guards, result}])
  # => [%Movie{title: "Rush", ...}, ...]
  ```

  Get all movies title names, that were directed by Tarantino before the year 2000:

  ```
  # Using guards only here, but you can mix and match with head.
  # You can also use a nested `{:andalso, guard1, guard2}` tuple
  # here instead.
  #
  # We used the result value `[:"$2"]` so it only returns the
  # second (i.e. title) field. Because of this, we're also not
  # coercing the results.

  match_head = {Movie, :"$1", :"$2", :"$3", :"$4"}
  result = [:"$2"]
  guards = [{:<, :"$3", 2000}, {:==, :"$4", "Quentin Tarantino"}]

  Memento.Query.select_raw(Movie, [{match_head, guards, result}], coerce: false)
  # => ["Reservoir Dogs", "Pulp Fiction", ...]
  ```

  Get all movies directed by Tarantino or Spielberg, after the year 2010:

  ```
  match_head = {Movie, :"$1", :"$2", :"$3", :"$4"}
  result = [:"$_"]
  guards = [
    {:andalso,
      {:>, :"$3", 2010},
      {:orelse,
        {:==, :"$4", "Quentin Tarantino"},
        {:==, :"$4", "Steven Spielberg"},
      }
    }
  ]

  Memento.Query.select_raw(Movie, [{match_head, guards, result}], coerce: true)
  # => [%Movie{...}, ...]
  ```

  ## Notes

  - It's important to note that for customized results (not equal to
  `:"$_"`), you should specify `coerce: false`, so it doesn't raise errors.

  - Unlike the `select/3` method, the `operation` values the `guard` tuples
  take in this method are Erlang atoms, not Elixir ones. For example,
  instead of `:and` & `:or`, they will be `:andalso` & `:orelse`. Similarly,
  you will have to use `:"/="` instead of `:!=` and `:"=<"` instead of `:<=`.

  See the [`Match Specification`](http://erlang.org/doc/apps/erts/match_spec.html)
  docs, `:mnesia.select/2` and `:ets.select/2` more details and examples.
  """
  @spec select_raw(Table.name, term, options) :: list(Table.record) | list(term)
  def select_raw(table, match_spec, opts \\ []) do
    # Default options
    lock   = Keyword.get(opts, :lock, :read)
    limit  = Keyword.get(opts, :limit, nil)
    coerce = Keyword.get(opts, :coerce, true)

    # Use select/4 if there is limit, otherwise use select/3
    args =
      case limit do
        nil   -> [table, match_spec, lock]
        limit -> [table, match_spec, limit, lock]
      end

    # Execute select method with the no. of args
    result = Mnesia.call(:select, args)

    # Coerce result conversion if `coerce: true`
    case coerce do
      true  -> coerce_records(result)
      false -> result
    end
  end




  @doc """
  Delete a Record in the given table for the specified key.

  This method takes a `Memento.Table` name and a key, and deletes all
  records with that key (There can be more than one for table type
  of `bag`). Options default to `[lock: :write]`.

  If you want to delete a record, by passing the record itself as
  the argument, see `delete_record/2`.


  ## Examples

  ```
  # Delete a Blog Post record with the id `10` (primary key)
  Memento.Query.delete(Blog.Post, 10)
  ```
  """
  @spec delete(Table.name, term, options) :: :ok
  def delete(table, key, opts \\ []) do
    lock = Keyword.get(opts, :lock, :write)

    Mnesia.call(:delete, [table, key, lock])
  end




  @doc """
  Delete the given Memento record object.

  This method accepts a `t:Memento.Table.record/0` object and deletes
  that from its table. A complete record object needs to be specified
  for this to work. Options default to `[lock: :write]`.

  This method is especially useful in Tables of type `bag` where
  multiple records can have the same key. Also see `delete/3`.


  ## Examples

  Consider an `Email` table of type `bag`, with two attributes;
  `user_id` and `email`, where `user_id` is the primary key. The Table
  contains all email addresses for a given user.

  ```
  # Calling `delete` will delete all emails for a `user_id`:
  Memento.Query.delete(Email, user_id)

  # To delete a specific record, you have to pass the entire object:
  email_record = %Email{user_id: 5, email: "a.specific@email.addr"}
  Memento.Query.delete_record(email_record)
  ```
  """
  @spec delete_record(Table.record, options) :: :ok
  def delete_record(record = %{__struct__: table}, opts \\ []) do
    record = Query.Data.dump(record)
    lock = Keyword.get(opts, :lock, :write)

    Mnesia.call(:delete_object, [table, record, lock])
  end





  # Private Helpers
  # ---------------


  # Coerce results when is simple list or tuple
  defp coerce_records(records) when is_list(records) do
    Enum.map(records, &Query.Data.load/1)
  end

  defp coerce_records({records, _term}) when is_list(records) do
    # TODO: Use this {coerce_records(records), term}
    coerce_records(records)
  end

  defp coerce_records(:"$end_of_table"), do: []


  # Raises error if tuple size and no. of attributes is not equal
  defp validate_match_pattern!(table, pattern) do
    same_size? = (tuple_size(pattern) == table.__info__().size)

    unless same_size? do
      Memento.Error.raise(
        "Match Pattern length is not equal to the no. of attributes"
      )
    end
  end


  # Ensures that a record has a primary key present if autoincrement
  # has been enabled, before it can be written
  defp prepare_record_for_write!(table, record) do
    info     = table.__info__()
    autoinc? = Definition.has_autoincrement?(table)
    primary  = Map.get(record, info.primary_key)

    cond do
      # If primary key is specified, don't do anything to the record
      not is_nil(primary) ->
        record

      # If primary key is not specified but autoincrement is enabled,
      # get the last numeric key and increment its value
      is_nil(primary) && autoinc? ->
        next_key = autoincrement_key_for(table)
        Map.put(record, info.primary_key, next_key)

      # If primary key is not specified and there is no autoincrement
      # enabled either, raise an error
      is_nil(primary) ->
        Memento.Error.raise(
          "Memento records cannot have a nil primary key unless autoincrement is enabled"
        )
    end
  end


  # Get the next numeric key (for ordered sets w/ autoincrement)
  #
  # It gets a list of all_keys for a table, selects the numeric
  # ones, find the maximum value and adds one to it.
  #
  # NOTE:
  # See if this implementation is efficient and does not create
  # any kinds of race conditions. Maybe also use some kind of
  # counter, so a key that was used for a previously deleted
  # record is not used again (like SQL)?
  @default_value 0
  @increment_by  1
  defp autoincrement_key_for(table) do
    :all_keys
    |> Mnesia.call([table])
    |> Enum.filter(&is_number/1)
    |> Enum.max(fn -> @default_value end)
    |> Kernel.+(@increment_by)
  end

end
