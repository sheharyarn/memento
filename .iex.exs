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

alias Definitions.Tables.User, as: U


# User Table
t = table = U
Table.create(t)


# Transaction Helpers
trx = &Support.Mnesia.transaction/1
mrx = &:mnesia.transaction/1

