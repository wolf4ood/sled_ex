defmodule Sled.DB do
    defstruct [:db, :codec]

    alias Sled.DB

    def wrap(db) do
        %DB { db: db, codec: Sled.Utils}
    end
end