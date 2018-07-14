defmodule Memento.Tests.Mnesia do
  use Memento.Support.Case

  alias Memento.Mnesia
  require Mnesia


  describe "#call" do
    @func :system_info
    @args [:is_running]

    test "delegates method calls to the mnesia module" do
      assert :yes == Mnesia.call(@func, @args)
    end
  end

end
