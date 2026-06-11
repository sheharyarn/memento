## Simple Error Modules
## --------------------

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
