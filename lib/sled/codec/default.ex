defmodule Sled.Codec.Default do
  def decode(other), do: other

  def encode(val) when is_binary(val), do: val
end
