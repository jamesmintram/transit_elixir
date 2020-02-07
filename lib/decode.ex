defmodule TransitElixir.Decode do

  alias TransitElixir.Cache
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

  def decode("~u" <> uuid, ctx) do
    {%Types.UUID{value: uuid}, ctx}
  end

  def decode("~:" <> sym, ctx) do
    {String.to_atom(sym), ctx}
  end

  def decode(nil, ctx), do: {nil, ctx}

  def decode("~zNaN", ctx), do: {:nan, ctx}
  def decode("~zINF", ctx), do: {:inf, ctx}
  def decode("~z-INF", ctx), do: {:neginf, ctx}

  def decode(["~#set", set_values], ctx), do: decode_set(set_values, ctx)
  def decode(%{"~#set" => set_values}, ctx), do: decode_set(set_values, ctx)

  def decode(["~#cmap", map_values], ctx), do: decode_compound_map(map_values, ctx)
  def decode(%{"~#cmap" => map_values}, ctx), do: decode_compound_map(map_values, ctx)

  def decode(%{"~#list" => list}, ctx), do: decode_list(list, ctx)
  def decode(["~#list", list], ctx), do: decode_list(list, ctx)

  def decode(["~#'" , val], ctx), do: decode_value(val, ctx)
  def decode(%{"~#'" => val}, ctx), do: decode_value(val, ctx)

  def decode("~$" <> sym, ctx), do: {%Types.Symbol{value: sym}, ctx}
  def decode("~" <> str, ctx), do: {str, ctx}
  def decode(value, ctx) when is_number(value), do: {value, ctx}
  def decode(value, ctx) when is_binary(value), do: {value, ctx}
  def decode(value, ctx) when is_boolean(value), do: {value, ctx}

  def decode(["^ " | map_values], ctx) do
    values = map_values
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {decode(a), decode(b)} end)
    |> Map.new
    #TODO: Reduce
    {values, ctx}
  end

  def decode(%{} = value, ctx) do
    #TODO: Reduce
    value
    |> Enum.map(fn {k, v} -> {decode(k), decode(v)} end)
    |> Map.new()
  end

  # vector
  def decode(value, ctx) when is_list(value) do
    #TODO: Reduce
    Enum.map(value, fn a -> decode(a) end)
  end

  def decode(value, ctx) do
    IO.puts("Unknown: " <> inspect(value))
    {nil, ctx}
  end

  def decode(value) do
    decode(value, Cache.create())
  end
end
