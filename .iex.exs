require Logger
alias Memento.{
  Table,
  Query,
  Schema,
  Mnesia,
  Transaction,

  Error,
  MnesiaException,

  Support,
  Support.Definitions,
}


# Table Aliases
alias Definitions.Tables.User,   as: U
alias Definitions.Tables.Email,  as: E
alias Definitions.Tables.Movie,  as: M
alias Definitions.Tables.Nested, as: N


# Create Tables
Table.create(U) |> inspect |> Logger.debug
Table.create(E) |> inspect |> Logger.debug
Table.create(M) |> inspect |> Logger.debug
Table.create(N) |> inspect |> Logger.debug


# Seed with some values
U.seed
E.seed
M.seed
N.seed


# Transaction Helpers
trx = &Support.Mnesia.transaction/1
mrx = &:mnesia.transaction/1


# Select Query Helper
select = fn (table, query, opts) ->
  Memento.transaction! fn ->
    Query.select(table, query, opts)
  end
end


# Raw Query Helper
raw = fn (table, match_spec, opts) ->
  Memento.transaction! fn ->
    Query.select_raw(table, match_spec, opts)
  end
end

