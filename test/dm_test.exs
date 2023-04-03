defmodule DMTest do
  use ExUnit.Case
  doctest DM

  test "greets the world" do
    assert DM.hello() == :world
  end
end
