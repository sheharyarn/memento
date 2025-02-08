defmodule Memento.MnesiaException do
  alias __MODULE__

  # Don't raise this error manually, instead call `Memento.Error.normalize`
  # or `Memento.Error.raise_from` to raise these errors.

  defexception [:message, :data]

  @moduledoc false
  @newline "\n   "



  # Build the Exception struct
  def build(error) do
    message =
      "Mnesia operation failed" <> @newline <>
      info(error) <> @newline <>
      "Mnesia Error: " <> inspect(error)

    %MnesiaException{
      data: error,
      message: message,
    }
  end


  # Fetch Mnesia's description of the error
  defp info({code, _, _}), do: info(code)
  defp info({code, _}),    do: info(code)
  defp info(code) do
    desc = :mnesia.error_description(code)

    cond do
      is_list(desc) -> to_string(desc)
      true -> inspect(desc)
    end
  end

end
