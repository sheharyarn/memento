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
alias Definitions.Tables.User,  as: U
alias Definitions.Tables.Email, as: E
alias Definitions.Tables.Movie, as: M

# Create Tables
Table.create(U)
Table.create(E)
Table.create(M)

# Seed with some values
U.seed
E.seed
M.seed


# Transaction Helpers
raw = &Support.Mnesia.select_raw/3
trx = &Support.Mnesia.transaction/1
mrx = &:mnesia.transaction/1

