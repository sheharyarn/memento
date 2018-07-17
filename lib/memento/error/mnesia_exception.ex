defmodule Memento.MnesiaException do
  alias __MODULE__

  defexception [:message, :data]

  @moduledoc false
  @message "Mnesia Operation failed with:\n     "



  # Re-raise Mnesia exits as Exceptions
  defmacro raise(data) do
    quote do
      data = MnesiaException.fetch(unquote(data))

      raise MnesiaException,
        message: (unquote(@message) <> inspect(data)),
        data: data
    end
  end


  # Parse the data returned from an Mnesia Exit Exception
  def fetch({:aborted, data}), do: data
  def fetch({:error, data}),   do: data
  def fetch(data),             do: data

end
