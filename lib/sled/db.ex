defmodule Sled.DB do
  defstruct [:db, :codec]

  alias Sled.DB

  def wrap(db, codec \\ Sled.Codec.Default) do
    codec = codec || Sled.Codec.Default

    %DB{db: db, codec: codec}
  end
end
