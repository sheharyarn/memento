defmodule Memento.Support.Case do
  use ExUnit.CaseTemplate

  @moduledoc """
  Default Test Case with important aliases/imports
  """


  using do
    quote do
      alias Memento.Support
    end
  end


  setup _tags do
    Memento.Support.Mnesia.reset
  end

end
