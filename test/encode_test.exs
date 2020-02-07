defmodule EncodeTest do
  use ExUnit.Case

  alias TransitElixir.Encode
  alias TransitElixir.Decode

  @posts_paths [
    # "nil",
    # "one_keyword",
    # "one_string",
    # "one",
    # "set_empty",
    # "set_nested",
    # "true",
    # "false",
    # "ints",
    #"doubles_interesting",
    # "doubles_small",
    # "keywords",

    # "one_uuid",
    # "uuids",

    # "list_empty",
    # "list_mixed",
    # "list_nested",
    # "list_simple",

    # "symbols",

    # "zero",
    # "small_ints",

    # "map_unrecognized_vals",

    # "vector_empty",
    # "vector_simple",
    # "vector_nested",
    # "vector_mixed",
    # "vector_unrecognized_vals",

    #"set_simple",
    "set_nested",
  ]

  @order_dependent [
    # "map_string_keys",
    # "map_vector_keys",
    # "map_simple",
    # "set_simple",
    # "set_mixed",
  ]

  test "recode" do
    for path <- @order_dependent do
      path = "priv/examples/0.8/simple/" <> path <> ".json"
      json_data = File.read!(path) |> Jason.decode!()

      data = Decode.decode(json_data)
      recoded_data = Decode.decode(Encode.encode(data))

      assert data == recoded_data
    end
  end

  test "encode" do
    for path <- @posts_paths do

      path = "priv/examples/0.8/simple/" <> path <> ".json"
      json_data = File.read!(path) |> Jason.decode!()

      encoded_json_data = Encode.encode(Decode.decode(json_data))
      IO.puts(inspect(encoded_json_data))
      assert json_data == encoded_json_data
    end

  end
end
