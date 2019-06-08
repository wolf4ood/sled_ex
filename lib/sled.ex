defmodule Sled do
  def open(path) do
    with {:ok, db} <- Sled.Native.start_default(path),
         handle <- Sled.DB.wrap(db) do
      {:ok, handle}
    end
  end

  def get(handle, key) do
    Sled.Native.get(handle.db, handle.codec.encode(key))
    |> handle.codec.decode()
  end

  def set(handle, key, value) do
    Sled.Native.set(handle.db, handle.codec.encode(key), handle.codec.encode(value))
  end

  def del(handle, key) do
    Sled.Native.del(handle.db, handle.codec.encode(key))
  end
end
