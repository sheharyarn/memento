defmodule Memento.MnesiaException do
  alias __MODULE__

  @moduledoc false
  @newline "\n   "

  defexception [:message, :data]



  # Re-raise Mnesia exits as Exceptions
  defmacro raise(data) do
    quote(bind_quoted: [data: data]) do
      raise MnesiaException.build(data)
    end
  end



  # Build the Exception struct
  def build(error) do
    error = fetch(error)
    message =
      "Mnesia operation failed" <> @newline <>
      info(error) <> @newline <>
      "Mnesia Error: " <> inspect(error)

    %MnesiaException{
      data: error,
      message: message,
    }
  end



  # Parse the data returned from an Mnesia Exit Exception
  defp fetch({:aborted, data}), do: data
  defp fetch({:error, data}),   do: data
  defp fetch(data),             do: data


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
