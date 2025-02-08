defmodule Memento.Support.Case do
  use ExUnit.CaseTemplate

  @moduledoc """
  Default Test Case with important aliases/imports
  """


  using do
    quote do
      alias Memento.Support
      alias Memento.Support.Definitions.Tables

      import Support.Mnesia, only: [
        transaction:  1,
        transaction!: 1,
      ]
    end
  end


  setup tags do
    unless tags[:async] do
      Memento.Support.Mnesia.reset
    end

    :ok
  end

end
