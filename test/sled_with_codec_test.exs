defmodule SledTestWithCodec do
  use ExUnit.Case
  doctest Sled

  setup do
    path = Path.join(__DIR__, "test_codec.sled")

    {:ok, db} = Sled.open(path, codec: Sled.Codec.Term)

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

  test "should set/get number key", %{db: db} do
    assert :ok == Sled.set(db, 1, "value")

    assert {:ok, "value"} == Sled.get(db, 1)
  end

  test "should not found a key", %{db: db} do
    assert :not_found = Sled.get(db, 10)
  end

  test "should set/get a complex value", %{db: db} do
    assert :ok == Sled.set(db, 1, ["v1", "v2", 1, {32, 34.0}])

    assert {:ok, ["v1", "v2", 1, {32, 34.0}]} == Sled.get(db, 1)
  end

  test "should set/get/del string key", %{db: db} do
    assert :ok == Sled.set(db, "key", "value")

    assert {:ok, "value"} == Sled.get(db, "key")

    assert :ok == Sled.del(db, "key")

    assert :not_found == Sled.get(db, "key")
  end

  test "should scan keys", %{db: db} do
    Enum.each(1..9, &(:ok = Sled.set(db, &1, &1)))

    assert {:ok, 1} == Sled.get(db, 1)

    assert {:ok, cursor} = Sled.scan(db, 1)

    assert Enum.to_list(1..9) |> Enum.map(fn x -> {x, x} end) ==
             cursor |> Enum.into([])
  end


  test "should scan keys reverse", %{db: db} do
    Enum.each(1..9, &(:ok = Sled.set(db, &1, &1)))

    assert {:ok, 1} == Sled.get(db, 1)

    assert {:ok, cursor} = Sled.scan(db, 2, [reverse: true] )

    assert Enum.to_list(1..2) |> Enum.map(fn x -> {x, x} end) |> Enum.reverse() ==
             cursor |> Enum.into([])
  end
  
end
