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


# User Table
t = table = Definitions.Tables.User
Table.create(t)


# Transaction Helpers
trx = &Support.Mnesia.transaction/1
mrx = &:mnesia.transaction/1

