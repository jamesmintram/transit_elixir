defmodule DecodeTest do
  use ExUnit.Case

  alias TransitElixir.Reader

  @posts_paths [
    "map_string_keys",
    "false",
    "true",
    "keywords",
    "strings_hat",
    "strings_tilde",

    "list_empty",
    "list_mixed",
    # "list_nested", NEEDS CACHE SUPPORT
    "list_simple",

    "map_10_items",
    #"map_10_nested",
    #"map_1935_nested", NEEDS CACHE, NOTE SOME CACHE KEYS DOUBLE CHAR

    "map_simple",
    "map_string_keys",
    "map_unrecognized_vals",
    "map_vector_keys",

    "nil",

    "one_keyword",
    "one_string",

    "one_symbol",
    "one",

    "set_empty",
    "set_mixed",
    #"set_nested",
    "set_simple",

    "small_ints",
    "small_strings",
    "strings_hash",
    "strings_hat",
    "strings_tilde",
    "symbols",

    "vector_empty",
    "vector_mixed",
    "vector_simple",
    "vector_special_numbers",

    "uuids",
  ]

  test "decode" do
    for path <- @posts_paths do
      normal_path = "priv/examples/0.8/simple/" <> path <> ".json"
      verbose_path = "priv/examples/0.8/simple/" <> path <> ".verbose.json"

      normal = Reader.from_file!(normal_path)
      verbose = Reader.from_file!(verbose_path)

      assert verbose == normal
    end

  end
end
