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
    Definition.validate_options!(opts)

    quote do
      opts = unquote(opts)

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
    |> handle_for_bang!
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
    |> Memento.Mnesia.handle_result
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
    |> Memento.Mnesia.handle_result
  end





  # Private Helpers
  # ---------------


  # Handle Result for Bang Methods
  defp handle_for_bang!(:ok), do: :ok
  defp handle_for_bang!(error) do
    Memento.Error.raise_from_code(error)
  end

end

