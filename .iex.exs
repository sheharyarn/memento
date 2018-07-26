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
alias Definitions.Tables.Movie, as: M

# Create/Seed Tables
Table.create(U)
Table.create(M)
U.seed
M.seed


# Transaction Helpers
raw = &Support.Mnesia.select_raw/3
trx = &Support.Mnesia.transaction/1
mrx = &:mnesia.transaction/1

