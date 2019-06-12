defmodule SledTest do
  use ExUnit.Case
  doctest Sled

  setup_all do
    path = Path.join(__DIR__, "test.sled")

    {:ok, db} = Sled.open(path)

    on_exit(fn ->
      File.rm_rf(path)
      :ok
    end)

    {:ok, %{db: db}}
  end

  test "should set/get string key", %{db: db} do
    assert :ok == Sled.set(db, "key", "value")

    assert {:ok, "value"} == Sled.get(db, "key")
  end

  test "should set/get binary key", %{db: db} do
    assert :ok == Sled.set(db, <<1>>, "value")

    assert {:ok, "value"} == Sled.get(db, <<1>>)
  end

  test "should not found a key", %{db: db} do
    assert :not_found = Sled.get(db, <<1, 2>>)
  end

  test "should set/get/del string key", %{db: db} do
    assert :ok == Sled.set(db, "key", "value")

    assert {:ok, "value"} == Sled.get(db, "key")

    assert :ok == Sled.del(db, "key")

    assert :not_found == Sled.get(db, "key")
  end

  test "should scan keys", %{db: db} do
    Enum.each(1..9, &(:ok = Sled.set(db, to_string(&1), to_string(&1))))

    assert {:ok, "1"} == Sled.get(db, "1")

    assert {:ok, cursor} = Sled.scan(db, "1")

    assert Enum.to_list(1..9) |> Enum.map(fn x -> {to_string(x), to_string(x)} end) ==
             cursor |> Enum.into([])
  end
end
