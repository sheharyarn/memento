alias Memento.{
  Table,
  Query,
  Schema,
  Mnesia,

  Error,
  MnesiaException,

  Support,
  Support.Definitions,
}


# User Table
t = table = Definitions.Tables.User
Table.create(t)


# Transaction Helper
trx = &Support.Mnesia.transaction/1

