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



  @doc false
  defmacro __using__(opts) do
    validate_options!(opts)
  end



  # Private Helpers
  # ---------------


  defp validate_options!(opts) do
    error =
      cond do
        !Keyword.keyword?(opts) ->
          "Invalid options specified"

        opts[:attributes] == nil ->
          "Table attributes not specified"

        !is_list(opts[:attributes]) ->
          "Invalid attributes specified"

        !Enum.all?(opts[:attributes], &is_atom/1) ->
          "Invalid attributes specified"

        true ->
          nil
      end

    case error do
      nil   -> :ok
      error -> raise Memento.Error, message: error
    end
  end

end

