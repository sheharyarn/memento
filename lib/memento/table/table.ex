defmodule Memento.Table do
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

  ## Options

  - `attributes` - A required list of atoms representing the attribute names
    of the records of the table. Must have at least two attributes, where the
    first one is the primary key.

  - `type` - One of `:set`, `:ordered_set`, or `:bag`. Default is `:set`. In
    a `:set`, all records have unique keys. In a `:bag`, several records can
    have the same key, but the record content is unique. If a non-unique
    record is stored, the old conflicting records are overwritten.

  - `index` - List of fields to index.

  The only required option is `attributes`. See `:mnesia.create_table/2` for
  a full list of options. See the following example that uses more options:


  ```
  defmodule Blog.Post do
    use Memento.Table,
      attributes: [:id, :title, :content, :status, :author_id],
      index: [:status, :author_id],
      type: :ordered_set
  end
  ```
  """





  # Type Definitions
  # ----------------


  @typedoc "A Memento.Table module"
  @type table :: module()

  @typedoc "A Memento.Table data struct"
  @type data :: map()





  # Use Macro
  # ---------


  @doc false
  defmacro __using__(opts) do
    validate_options!(opts)

    quote do
      opts = unquote(opts)

      @table_attrs Keyword.get(opts, :attributes)
      @table_type  Keyword.get(opts, :type, :set)
      @table_opts  Keyword.drop(opts, [:attributes, :type])

      @query_map  Memento.Query.Translate.build_map(@table_attrs)
      @query_base Memento.Query.Translate.build_base(__MODULE__, @table_attrs)

      @info %{
        meta: Memento.Table,
        table_attributes: @table_attrs,
        table_type: @table_type,
        table_opts: @table_opts,
        query_base: @query_base,
        query_map: @query_map,
      }

      defstruct [{:__meta__, Memento.Table} | @table_attrs]
      def __info__, do: @info
    end
  end




  # Private Helpers
  # ---------------


  @allowed_types [:set, :ordered_set, :bag]


  # Validate options given to __using__
  defp validate_options!(opts) do
    error = cond do
      !Keyword.keyword?(opts) ->
        "Invalid options specified"

      true ->
        attrs = Keyword.get(opts, :attributes)
        type  = Keyword.get(opts, :type, :set)
        index = Keyword.get(opts, :index, [])

        cond do
          attrs == nil ->
            "Table attributes not specified"

          !is_list(attrs) ->
            "Invalid attributes specified"

          !Enum.all?(attrs, &is_atom/1) ->
            "Invalid attributes specified"

          !is_list(index) ->
            "Invalid index list specified"

          !Enum.all?(index, &is_atom/1) ->
            "Invalid index list specified"

          !Enum.member?(@allowed_types, type) ->
            "Invalid table type specified"

          true ->
            nil
      end
    end

    case error do
      nil   -> :ok
      error -> raise Memento.Error, message: error
    end
  end

end

