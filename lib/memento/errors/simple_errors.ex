## Simple Error Modules
## --------------------


# NOTE TO SELF:
# Please don't try to be over-efficient and edgy by dynamically
# defining these exceptions from a list of Module names. It looks
# really fucking bad.



defmodule Memento.NoTransactionError do
  @moduledoc false
  defexception [:message]
end

defmodule Memento.AlreadyExistsError do
  @moduledoc false
  defexception [:message]
end

defmodule Memento.DoesNotExistError do
  @moduledoc false
  defexception [:message]
end

defmodule Memento.InvalidOperationError do
  @moduledoc false
  defexception [:message]
end

