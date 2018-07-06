defmodule MementoTest do
  use ExUnit.Case
  doctest Memento

  test "greets the world" do
    assert Memento.hello() == :world
  end
end
