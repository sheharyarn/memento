defmodule Memento.Query do
  require Memento.Mnesia

  alias Memento.Query
  alias Memento.Table
  alias Memento.Mnesia


  @moduledoc """
  Module to read/write from Memento Tables. All of the methods in
  this module need to be executed within the context of a Memento
  Transaction.
  """



  # Type Definitions
  # ----------------


  @typedoc "Types of locks that can be acquired"
  @type lock :: :read | :write | :sticky_write





  # Public API
  # ----------


  @doc """
  Finds the Memento record for the given id in the specified table.

  If no record is found, `nil` is returned. You can also pass an
  optional 3rd argument `lock`, which acquires a lock of that type.
  Defaults to `:read`. See `t:lock` for more details.

  This method works a bit differently from the original `:mnesia.read/3`
  when the table type is `:bag`. Since a bag can have many records
  with the same key, this returns only the first one. If you want to
  fetch all records with the given key, use `match/2` or `select/2`.
  """
  @spec read(Table.t, any, lock) :: Table.data | nil
  def read(table, id, lock \\ :read) do
    case Mnesia.call(:read, [table, id, lock]) do
      []           -> nil
      [record | _] -> Query.Data.load(record)
    end
  end


  def write
  def all
  def first
  def match
  def select

end
