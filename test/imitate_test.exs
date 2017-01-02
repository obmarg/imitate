defmodule OriginalModule do
  def funktion_one(_an_arg) do
    raise "This should never be called"
  end

  def funktion_two(_an_arg, _another_arg) do
    raise "This should never be called"
  end
end

defmodule ImitateTest do
  use ExUnit.Case
  doctest Imitate

  alias Imitate

  defmodule FakeModule do
    require Imitate
    Imitate.module(OriginalModule)
  end

  test "that FakeModule has the same functions as OriginalModule" do
    assert OriginalModule.module_info[:exports] == FakeModule.module_info[:exports]
  end

  test "that calls in FakeModule are recorded as messages to the current process." do
    Imitate.start_link(FakeModule)

    FakeModule.funktion_one("test")
    assert_receive {Imitate.Call, :funktion_one, {"test"}}
    refute_receive _

    FakeModule.funktion_one("test")
    FakeModule.funktion_two("test", "oh test")
    assert_receive {Imitate.Call, :funktion_one, {"test"}}
    assert_receive {Imitate.Call, :funktion_two, {"test", "oh test"}}
    refute_receive _
  end
end
