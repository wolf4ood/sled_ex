defmodule Sled do
  def open(path, opts \\ []) do
    codec = opts[:codec]

    with {:ok, db} <- Sled.Native.start_default(path),
         handle <- Sled.DB.wrap(db, codec) do
      {:ok, handle}
    end
  end

  def get(%{db: db, codec: codec}, key) do
    Sled.Native.get(db, codec.encode(key))
    |> codec.decode()
  end

  def set(%{db: db, codec: codec}, key, value) do
    Sled.Native.set(db, codec.encode(key), codec.encode(value))
  end

  def del(%{db: db, codec: codec}, key) do
    Sled.Native.del(db, codec.encode(key))
  end

  def scan(%{db: db, codec: codec}, key, opts \\ []) do
    with {:ok, cursor} <- Sled.Native.scan(db, codec.encode(key), opts),
         handle <- Sled.Cursor.wrap(cursor, codec) do
      {:ok, handle}
    end
  end
end
