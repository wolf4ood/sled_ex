defmodule Sled.Codec do
  
  def decode({:ok, <<"_$sled:", encoded::binary>>}), do: {:ok, :erlang.binary_to_term(encoded)}
  def decode(<<"_$sled:", encoded::binary>>), do: :erlang.binary_to_term(encoded)
  def decode(other), do: other


  def encode(val) when is_binary(val), do: val
  def encode(val), do: "_$sled:" <> :erlang.term_to_binary(val)
end
