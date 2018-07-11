defmodule Memento.Support do
  alias Memento.Support

  @moduledoc "Helper functions for tests"


  # Capture Helpers
  defdelegate capture_io(fun),   to: ExUnit.CaptureIO
  defdelegate capture_log(fun),  to: ExUnit.CaptureLog


  defmodule Mnesia do
    @moduledoc "Mnesia-related helpers"

    def reset do
      Support.capture_log(fn ->
        Application.stop(:mnesia)
        :mnesia.delete_schema([node()])
        Application.start(:mnesia)
      end)
    end
  end

end
