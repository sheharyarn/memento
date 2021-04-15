defmodule Memento.Table do
  alias Memento.Table.Definition

  require Memento.Error
  require Memento.Mnesia



  @moduledoc """
  Defines a Memento Table schema for Mnesia


  ## Usage

  You can define an Mnesia Table by calling `use Memento.Table` with a few
  options in your module.

  ```
  defmodule Blog.Post do
    use Memento.Table, attributes: [:id, :title, :content]
  end
  ```

  Each table then must be created before you can interact with it. You can do
  that by calling `create/2`. It's usually a good idea to call this while
  your application is being started:

  ```
  Memento.Table.create(Blog.Post)
  ```


  ## Options

  The table definition and the `create/2` function both accept a keyword list
  specifying the options for the table:

  - `attributes` - A required list of atoms representing the attribute names
    of the records of the table. Must have at least two attributes, where the
    first one is the primary key.

  - `type` - One of `:set`, `:ordered_set`, or `:bag`. Default is `:set`. In
    a `:set`, all records have unique keys. In a `:bag`, several records can
    have the same key, but the record content is unique. If a non-unique
    record is stored, the old conflicting records are overwritten.

  - `index` - List of fields to index.

  - `autoincrement` - If the table is of the type `:ordered_set`, setting this
    `true` will automatically assign numeric values to non-nil primary keys
    when writing records (using `Memento.Query.write/2`). Will return an error
    if the table is not of the type `:ordered_set`.

  The only required option is `attributes`. See `:mnesia.create_table/2` for
  a full list of options. See the following example that uses more options:


  ```
  defmodule Blog.Post do
    use Memento.Table,
      attributes: [:id, :title, :content, :status, :author_id],
      index: [:status, :author_id],
      type: :ordered_set,
      autoincrement: true


    # You can also define other methods
    # or helper functions in the module
  end
  ```
  """





  # Type Definitions
  # ----------------


  @typedoc "A Memento.Table module"
  @type name :: module()

  @typedoc "A Memento.Table record data struct"
  @type record :: struct()

  @typedoc "Table storage/copy type"
  @type storage_type :: :ram_copies | :disc_copies | :disc_only_copies





  # Callbacks
  # ---------


  @doc """
  Returns Table definition information.

  Every defined `Memento.Table` via the `use` macro, will export this
  method, returning information about its attributes, structure, options
  and other details.
  """
  @callback __info__() :: map()





  # Use Macro
  # ---------


  @doc false
  defmacro __using__(opts) do
    opts = Macro.expand(opts, __CALLER__)

    quote do
      opts = unquote(opts)
      Definition.validate_options!(opts)

      @table_attrs Keyword.get(opts, :attributes)
      @table_type  Keyword.get(opts, :type, :set)
      @table_opts  Definition.build_options(opts)

      @query_map   Definition.build_map(@table_attrs)
      @query_base  Definition.build_base(__MODULE__, @table_attrs)

      @info %{
        meta:         Memento.Table,
        type:         @table_type,
        attributes:   @table_attrs,
        options:      @table_opts,
        query_base:   @query_base,
        query_map:    @query_map,
        primary_key:  hd(@table_attrs),
        size:         length(@table_attrs),
      }

      defstruct Definition.struct_fields(@table_attrs)
      def __info__, do: @info
    end
  end





  # Public API
  # ----------


  @doc """
  Creates a Memento Table for Mnesia.

  This must be called before you can interact with the table in any way.
  Uses the attributes specified in the table definition. Returns `:ok` on
  success or `{:error, reason}` on failure. Will raise an error if the
  passed module isn't a Memento Table.

  You can optionally pass a set of options keyword, which will override
  all options specified in the definition except `:attributes`.  See
  `:mnesia.create_table/2` for all available options.
  """
  @spec create(name, Keyword.t) :: :ok | {:error, any}
  def create(table, opts \\ []) do
    Definition.validate_table!(table)

    # Build new Options
    info = table.__info__()
    opts = Definition.merge_options(info.options, opts)

    # Validate Options
    type = info.type
    auto = Keyword.get(opts.memento, :autoincrement, false)


    cond do
      # Return error if autoincrement is used without ordered_set
      auto && (type != :ordered_set) ->
        {:error, {:autoincrement, "can only be used with :ordered_set"}}

      # Else create the Table
      true ->
        main = [attributes: info.attributes]
        mnesia_opts = Keyword.merge(opts.mnesia, main)

        :create_table
        |> Memento.Mnesia.call([table, mnesia_opts])
        |> Memento.Mnesia.handle_result
    end
  end




  @doc "Same as `create/2`, but raises error on failure."
  @spec create!(name, Keyword.t) :: :ok | no_return
  def create!(table, opts \\ []) do
    table
    |> create(opts)
    |> handle_for_bang!()
  end




  @doc """
  Deletes a Memento Table for Mnesia.

  Returns `:ok` on success and `{:error, reason}` on failure.
  """
  @spec delete(name) :: :ok | {:error, any}
  def delete(table) do
    Definition.validate_table!(table)

    :delete_table
    |> Memento.Mnesia.call([table])
    |> Memento.Mnesia.handle_result()
  end




  @doc "Same as `delete/1`, but raises error on failure."
  @spec delete!(name) :: :ok | no_return
  def delete!(table) do
    table
    |> delete()
    |> handle_for_bang!()
  end




  @doc """
  Makes a copy of a table at the given node.

  Especially useful when you want to replicate a table on another
  node on the fly, usually when connecting to it the first time.

  The argument `type` must be a valid `storage_type()` atom. This
  can also be used to create a replica of the internal `:schema`
  table.

  Also see `:mnesia.add_table_copy/3`.

  ## Example

  ```
  # Create an on-disc replica of `Users` table on another node
  Memento.Table.create_copy(Users, :some_node@host_x, :disc_copies)
  ```
  """
  @spec create_copy(name, node, storage_type) :: :ok | {:error, any}
  def create_copy(table, node, type) do
    :add_table_copy
    |> Memento.Mnesia.call_and_catch([table, node, type])
    |> Memento.Mnesia.handle_result()
  end




  @doc """
  Deletes the replica of a table on the specified node.

  When the last replica of a table is deleted, the table disappears
  entirely. This function can also be used to delete the replica of
  the internal `:schema` table which will cause the Mnesia node to
  be removed (Mnesia/Memento must be stopped first).

  Also see `:mnesia.del_table_copy/2`.
  """
  @spec delete_copy(name, node) :: :ok | {:error, any}
  def delete_copy(table, node) do
    :del_table_copy
    |> Memento.Mnesia.call_and_catch([table, node])
    |> Memento.Mnesia.handle_result()
  end




  @doc """
  Moves a table's copy from one node to the other.

  This operation preserves the storage type of the table. For example,
  a `:ram_copies` table when moved from one node, remains keeps its
  `:ram_copies` storage type on the new node.

  Other transactions can still read and write while it's being moved.
  This function cannot be called on the internal `:local_content`
  tables.

  Also see `:mnesia.move_table_copy/3`.
  """
  @spec move_copy(name, node, node) :: :ok | {:error, any}
  def move_copy(table, node_from, node_to) do
    :move_table_copy
    |> Memento.Mnesia.call_and_catch([table, node_from, node_to])
    |> Memento.Mnesia.handle_result()
  end




  @doc """
  Sets the storage type of a table for the specified node.

  Useful when you want to change the table's copy type on the fly,
  usually when connecting to a new, unsynchronized node on
  discovery at runtime.

  The argument `type` must be a valid `storage_type()` atom. This
  can also be used for the internal `:schema` table, but you should
  use `Memento.Schema.set_storage_type/2` instead.

  See `:mnesia.change_table_copy_type/3` for more details.


  ## Example

  ```
  Memento.Table.set_storage_type(MyTable, :node@host, :disc_copies)
  ```
  """
  @spec set_storage_type(name, node, storage_type) :: :ok | {:error, any}
  def set_storage_type(table, node, type) do
    :change_table_copy_type
    |> Memento.Mnesia.call_and_catch([table, node, type])
    |> Memento.Mnesia.handle_result()
  end




  @doc """
  Returns all table information.

  Optionally accepts an extra atom argument `key` which returns result
  for only that key. Will throw an exception if the key is invalid. See
  `:mnesia.table_info/2` for a full list of allowed keys.
  """
  @spec info(name, atom) :: any
  def info(table, key \\ :all) do
    Definition.validate_table!(table)
    Memento.Mnesia.call(:table_info, [table, key])
  end




  @doc """
  Deletes all entries in the given Memento Table.

  Returns `:ok` on success and `{:error, reason}` on failure.
  """
  @spec clear(name) :: :ok | {:error, any}
  def clear(table) do
    Definition.validate_table!(table)

    :clear_table
    |> Memento.Mnesia.call([table])
    |> Memento.Mnesia.handle_result()
  end




  @doc """
  Wait until specified tables are ready.

  Before performing some tasks, it's necessary that certain tables
  are ready and accessible. This call hangs until all tables
  specified are accessible, or until timeout is reached
  (default: 3000ms).

  The `timeout` value can either be `:infinity` or an integer
  representing time in milliseconds. If you pass a Table/Module that
  does not exist along with `:infinity` as timeout, it will hang your
  process until that table is created and ready.

  This method can be accessed directly on the `Memento` module as well.

  For more information, see `:mnesia.wait_for_tables/2`.

  ## Examples

  ```
  # Wait until the `Movies` table is ready
  Memento.Table.wait(Movies, :infinity)

  # Wait a maximum of 3 seconds until the two tables are ready
  Memento.wait([TableA, TableB])
  ```
  """
  @spec wait(list(name), integer | :infinity) :: :ok | {:timeout, list(name)} | {:error, any}
  def wait(tables, timeout \\ 3000) do
    tables = List.wrap(tables)
    Memento.Mnesia.call(:wait_for_tables, [tables, timeout])
  end





  # Private Helpers
  # ---------------


  # Handle Result for Bang Methods
  defp handle_for_bang!(:ok), do: :ok
  defp handle_for_bang!(error) do
    Memento.Error.raise_from_code(error)
  end

end

