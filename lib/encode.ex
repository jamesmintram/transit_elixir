defmodule TransitElixir.Encode do

  alias TransitElixir.Types
  alias TransitElixir.Cache

  def encode_string("~" <> _ = str), do: "~" <> str
  def encode_string("^" <> _ = str), do: "~" <> str
  def encode_string("`" <> _ = str), do: "~" <> str
  def encode_string(str), do: str

  def encode_list(data, ctx) do
    {tag, ctx} = Cache.cache("~#list", ctx)

    {list, ctx} = data
    |> Enum.reduce({[], ctx},
      fn item, {lst, ctx} ->
        {val, ctx} = encode_item(item, ctx)
        {lst ++ [val], ctx}
      end)

    {[tag, list], ctx}
  end

  def encode_map(data, ctx) do

    simple_keys = Enum.all?(data,
      fn {k, _} ->
        cond do
          is_boolean(k) -> true
          is_number(k) -> true
          is_binary(k) -> true
          is_atom(k) -> true
          #TODO: Add support for Symbols here
          :else -> false
        end
      end)

    cacheable_keys = Enum.all?(data,
      fn {k, _} ->
        cond do
          is_binary(k) -> true
          is_atom(k) -> true
          #TODO: Add support for Symbols here
          :else -> false
        end
      end)

    #TODO: Improve this
    {values, ctx} = if cacheable_keys do
      data
      |> Enum.reduce({[], ctx},
        fn {k, v}, {lst, ctx} ->
          {tag, ctx} = encode_item(k, ctx)
          {value, ctx} = encode_item(v, ctx)

          {lst ++ [tag, value], ctx}
        end)
    else
      empty_cache = Cache.create()
      data
      |> Enum.reduce({[], ctx},
        fn {k, v}, {lst, ctx} ->
          {tag, _} = encode_item(k, empty_cache)
          {value, ctx} = encode_item(v, ctx)

          {lst ++ [tag, value], ctx}
        end)
    end

    cond do
      cacheable_keys ->
        {["^ "] ++ values, ctx}
      simple_keys ->
        {["^ "] ++ values, ctx}
      :else ->
        {tag, ctx} = Cache.cache("~#cmap", ctx)
        {[tag, values], ctx}
    end
  end

  def encode_item(%Types.UUID{} = data, ctx) do
    Cache.cache("~u" <> data.value, ctx)
  end
  def encode_item(%Types.Symbol{value: sym}, ctx) do
    Cache.cache("~$" <> sym, ctx)
  end
  def encode_item(%Types.List{value: list}, ctx) do
    encode_list(list, ctx)
  end

  def encode_item(nil, ctx), do: {nil, ctx}
  def encode_item(true, ctx), do: {true, ctx}
  def encode_item(false, ctx), do: {false, ctx}
  def encode_item(data, ctx) when is_binary(data), do: {encode_string(data), ctx}
  def encode_item(data, ctx) when is_number(data), do: {data, ctx}
  def encode_item(data, ctx) when is_atom(data), do: Cache.cache("~:" <> Atom.to_string(data), ctx)
  def encode_item(data, ctx) when is_list(data) do
    Enum.reduce(data, {[], ctx},
      fn item, {lst, ctx} ->
        {val, ctx} = encode_item(item, ctx)
        {lst ++ [val], ctx}
      end)
  end
  def encode_item(%MapSet{} = data, ctx) do
    {tag, ctx} = Cache.cache("~#set", ctx)

    {values, ctx} = Enum.reduce(data, {[], ctx},
      fn item, {lst, ctx} ->
        {val, ctx} = encode_item(item, ctx)
        {lst ++ [val], ctx}
      end)

    {[tag, values], ctx}
  end

  def encode_item(data, ctx) when is_map(data) do
    encode_map(data, ctx)
  end

  def encode_item(data, ctx) do
    IO.puts("Unknown: " <> inspect(data))
    {nil, ctx}
  end

  def encode(nil), do: ["~#'", nil]
  def encode(%Types.UUID{value: uuid}), do: ["~#'", "~u" <> uuid]
  def encode(%Types.Symbol{value: sym}), do: ["~#'", "~$" <> sym]
  def encode(%Types.List{value: list}) do
    {val, _} = encode_list(list, Cache.create())
    val
  end
  def encode(value) when is_boolean(value), do: ["~#'", value]
  def encode(data) when is_binary(data), do: ["~#'", encode_string(data)]
  def encode(data) when is_number(data), do: ["~#'", data]
  def encode(data) when is_atom(data), do: ["~#'", "~:" <> Atom.to_string(data)]

  def encode(data) do
    {val, _} = encode_item(data, Cache.create())
    val
  end
end
