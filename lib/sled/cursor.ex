defmodule Sled.Cursor do
  defstruct [:cursor, :codec]

  alias Sled.Cursor

  def wrap(cursor, codec) do
    %Cursor{cursor: cursor, codec: codec}
  end

  defimpl Enumerable do
    def count(_function), do: {:error, __MODULE__}
    def member?(_function, _value), do: {:error, __MODULE__}

    def slice(_function), do: {:error, __MODULE__}

    def reduce(%Cursor{cursor: _cursor, codec: _codec}, {:halt, acc}, _fun) do
      {:halted, acc}
    end

    def reduce(%Cursor{} = cursor, {:suspend, acc}, fun) do
      {:suspended, acc, &reduce(cursor, &1, fun)}
    end

    def reduce(%Cursor{cursor: raw, codec: codec} = cursor, {:cont, acc}, fun) do
      case Sled.Native.iter_next(raw) do
        :done ->
          {:done, acc}

        {key, value} ->
          reduce(cursor, fun.({codec.decode(key), codec.decode(value)}, acc), fun)
      end
    end
  end
end
