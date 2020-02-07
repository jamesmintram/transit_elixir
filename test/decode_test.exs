defmodule DecodeTest do
  use ExUnit.Case

  alias TransitElixir.Reader

  @posts_paths "priv/examples/0.8/simple/*.json"
    |> Path.wildcard()
    |> Enum.map(&String.trim_trailing(&1, ".json"))
    |> Enum.map(&String.trim_trailing(&1, ".verbose"))
    |> MapSet.new

  test "decode" do
    for path <- @posts_paths do
      normal_path = path <> ".json"
      verbose_path = path <> ".verbose.json"

      IO.puts(path)
      normal = Reader.from_file!(normal_path)
      verbose = Reader.from_file!(verbose_path)

      assert verbose == normal
    end

  end
end
