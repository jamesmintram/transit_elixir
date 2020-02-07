defmodule TransitElixir.Decode do

  alias TransitElixir.Types

  defp decode_set(set_values) do
    set_values
    |> Enum.map(fn b -> decode(b) end)
    |> MapSet.new
  end
  defp decode_compound_map(map_values) do
    map_values
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {decode(a), decode(b)} end)
    |> Map.new
  end
  defp decode_list(list) do
    %Types.List{value: Enum.map(list, fn a -> decode(a) end)}
  end
  defp decode_value(val) do
    decode(val)
  end

  #----------------------------------------------------------------------

  def decode("~u" <> uuid) do
    %Types.UUID{value: uuid}
  end

  def decode("~:" <> sym) do
    String.to_atom(sym)
  end

  def decode(nil), do: nil

  def decode("~zNaN"), do: :nan
  def decode("~zINF"), do: :inf
  def decode("~z-INF"), do: :neginf

  def decode(["~#set", set_values]), do: decode_set(set_values)
  def decode(%{"~#set" => set_values}), do: decode_set(set_values)

  def decode(["~#cmap", map_values]), do: decode_compound_map(map_values)
  def decode(%{"~#cmap" => map_values}), do: decode_compound_map(map_values)

  def decode(%{"~#list" => list}), do: decode_list(list)
  def decode(["~#list", list]), do: decode_list(list)

  def decode(["~#'" , val]), do: decode_value(val)
  def decode(%{"~#'" => val}), do: decode_value(val)

  def decode("~$" <> sym), do: %Types.Symbol{value: sym}
  def decode("~" <> str), do: str
  def decode(value) when is_number(value), do: value
  def decode(value) when is_binary(value), do: value
  def decode(value) when is_boolean(value), do: value

  def decode(["^ " | map_values]) do
    map_values
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {decode(a), decode(b)} end)
    |> Map.new
  end

  def decode(%{} = value) do
    value
    |> Enum.map(fn {k, v} -> {decode(k), decode(v)} end)
    |> Map.new()
  end

  # vector
  def decode(value) when is_list(value) do
    Enum.map(value, fn a -> decode(a) end)
  end

  def decode(value) do
    IO.puts("Unknown: " <> inspect(value))
    nil
  end
end
