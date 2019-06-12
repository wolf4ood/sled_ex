defmodule Sled.Native do
  use Rustler, otp_app: :sled_ex, crate: :sled_ex

  def start_default(_path), do: :erlang.nif_error(:nif_not_loaded)

  def get(_ref, _key), do: :erlang.nif_error(:nif_not_loaded)

  def del(_ref, _key), do: :erlang.nif_error(:nif_not_loaded)

  def set(_ref, _key, _value), do: :erlang.nif_error(:nif_not_loaded)

  def scan(_ref, _key, _opts), do: :erlang.nif_error(:nif_not_loaded)

  def iter_next(_ref), do: :erlang.nif_error(:nif_not_loaded)
end
