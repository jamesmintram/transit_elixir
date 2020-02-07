defmodule TransitElixir.Decode do

  alias TransitElixir.Cache
  alias TransitElixir.Types

  defp decode_set(set_values, ctx) do
    {_, ctx} = Cache.cache("~#set", ctx)

    {set_values, ctx} =
    Enum.reduce(set_values, {[], ctx},
      fn item, {lst, ctx} ->
        {val, ctx} = decode(item, ctx)
        {lst ++ [val], ctx}
      end)

    {MapSet.new(set_values), ctx}
  end

  defp decode_compound_map(map_values, ctx) do
    {_, ctx} = Cache.cache("~#cmap", ctx)

    {map_values, ctx} = map_values
    |> Enum.chunk_every(2)
    |> Enum.reduce({[], ctx},
      fn [k, v], {lst, ctx} ->
        {key, ctx} = decode(k, ctx)
        {val, ctx} = decode(v, ctx)

        {[{key, val} | lst], ctx}
      end)

    {Map.new(map_values), ctx}
  end

  defp decode_list(list_values, ctx) do
    {_, ctx} = Cache.cache("~#list", ctx)

    {list, ctx} = list_values
    |> Enum.reduce({[], ctx},
      fn item, {lst, ctx} ->
        {val, ctx} = decode(item, ctx)
        {lst ++ [val], ctx}
      end)

    {%Types.List{value: list}, ctx}
  end
  defp decode_value(val, ctx) do
    decode(val, ctx)
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

  def decode("^" <> cache_key, ctx) do
    case Cache.lookup(cache_key, ctx) do
      nil -> raise "Unknown cache key"
      tag -> decode(tag, ctx)
    end
  end

  def decode(["^" <> cache_key, items], ctx) do
    case Cache.lookup(cache_key, ctx) do
      nil -> raise "Unknown cache key"
      tag ->
        decode([tag, items], ctx)
    end
  end

  def decode(["~#'" , val], ctx), do: decode_value(val, ctx)
  def decode(%{"~#'" => val}, ctx), do: decode_value(val, ctx)

  def decode("~$" <> sym, ctx), do: {%Types.Symbol{value: sym}, ctx}
  def decode("~" <> str, ctx), do: {str, ctx}
  def decode(value, ctx) when is_number(value), do: {value, ctx}
  def decode(value, ctx) when is_binary(value), do: {value, ctx}
  def decode(value, ctx) when is_boolean(value), do: {value, ctx}

  def decode(["^ " | map_values], ctx) do
    {map_values, ctx} = map_values
    |> Enum.chunk_every(2)
    |> Enum.reduce({[], ctx},
      fn [k, v], {lst, ctx} ->
        {k, ctx} = Cache.cache(k, ctx)

        {key, ctx} = decode(k, ctx)
        {val, ctx} = decode(v, ctx)

        {[{key, val} | lst], ctx}
      end)

    {Map.new(map_values), ctx}
  end

  def decode(%{} = value, ctx) do
    {map_values, ctx} = value
    |> Enum.reduce({[], ctx},
      fn {k, v}, {lst, ctx} ->
        {key, ctx} = decode(k, ctx)
        {val, ctx} = decode(v, ctx)

        {[{key, val} | lst], ctx}
      end)

    {Map.new(map_values), ctx}
  end

  # vector
  def decode(value, ctx) when is_list(value) do
    Enum.reduce(value, {[], ctx},
      fn item, {lst, ctx} ->
        {val, ctx} = decode(item, ctx)
        {lst ++ [val], ctx}
      end)
  end

  def decode(value, ctx) do
    IO.puts("Unknown: " <> inspect(value))
    {nil, ctx}
  end

  def decode(value) do
    {data, _} = decode(value, Cache.create())
    data
  end
end
