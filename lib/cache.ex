defmodule TransitElixir.Cache do
  defstruct map: %{}

  def cache(val, %{} = cache) do
    case cache.map[val] do
      nil ->
        # TODO: Implement the cache key encoding
        {val, put_in(cache, [:map, val], "^0")}
      cache_key ->
        {cache_key, cache}
    end
  end

  def create() do
    %{map: %{}}
  end
end
