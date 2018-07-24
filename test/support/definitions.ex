defmodule Memento.Support.Definitions do
  defmodule Tables do
    @moduledoc "Helper table definitions"

    defmodule User do
      use Memento.Table, attributes: [:id, :name]
    end


    defmodule Movie do
      use Memento.Table,
        type: :ordered_set,
        attributes: [:id, :title, :year, :director]
    end

  end
end
