defmodule TransitElixir.Cache do
  defstruct map: %{}

  defp next_cache_key(cache) do
    count = map_size(cache.key_to_tag)

    # TODO: Add support for rollover of cache key

    upper = div(count, 44)
    lower = rem(count, 44)

    upper_c = 48 + upper
    lower_c = 48 + lower

    code = case upper do
      0 -> [lower_c]
      _ -> [upper_c, lower_c]
    end

    List.to_string(code)
  end

  def lookup(key, cache) do
    get_in(cache, [:key_to_tag, key])
  end

  def cache("^" <> _ = cache_key, ctx) do
    {cache_key, ctx}
  end

  #TODO: Not sure byte_size is the correct method (multi-char etc)
  def cache(tag, ctx) when byte_size(tag) < 4 do
    {tag, ctx}
  end

  def cache(tag, %{} = cache) do
    case get_in(cache, [:tag_to_key, tag]) do
      nil ->
        new_cache_key = next_cache_key(cache)

        cache = cache
        |> put_in([:tag_to_key, tag], new_cache_key)
        |> put_in([:key_to_tag, new_cache_key], tag)

        {tag, cache}
      cache_key ->
        {cache_key, cache}
    end
  end

  @spec create :: %{key_to_tag: %{}, tag_to_key: %{}}
  def create() do
    %{key_to_tag: %{},
      tag_to_key: %{}}
  end
end
