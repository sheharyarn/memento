defmodule Memento.Support.Definitions do
  defmodule Tables do
    @moduledoc "Helper table definitions"

    defmodule User do
      use Memento.Table, attributes: [:id, :name]
    end

  end
end
