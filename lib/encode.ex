defmodule TransitElixir.Encode do

  alias TransitElixir.Types

  def encode_list(data) do
    ["~#list", Enum.map(data, &encode_item(&1))]
  end

  def encode_map(data) do
    values = data
      |> Enum.map(fn {k, v} -> [encode_item(k), encode_item(v)]  end)
      |> Enum.concat()

    simple_keys = Enum.all?(data,
      fn {k, _} ->
        cond do
          is_boolean(k) -> true
          is_number(k) -> true
          is_binary(k) -> true
          is_atom(k) -> true
          :else -> false
        end
      end)

    if simple_keys do
      ["^ "] ++ values
    else
      ["~#cmap", values]
    end
  end

  def encode_item(%Types.UUID{} = data) do
    "~u" <> data.value
  end
  def encode_item(%Types.Symbol{value: sym}) do
    "~$" <> sym
  end
  def encode_item(%Types.List{value: list}) do
    encode_list(list)
  end

  def encode_item(nil), do: nil
  def encode_item(true), do: true
  def encode_item(false), do: false
  def encode_item(data) when is_binary(data), do: data
  def encode_item(data) when is_number(data), do: data
  def encode_item(data) when is_atom(data), do: "~:" <> Atom.to_string(data)
  def encode_item(data) when is_list(data) do
    Enum.map(data, &encode_item(&1))
  end
  def encode_item(%MapSet{} = data) do
    values = Enum.map(data, fn v -> encode_item(v) end)
    ["~#set", values]
  end

  def encode_item(data) when is_map(data) do
    encode_map(data)
  end

  def encode_item(data) do
    IO.puts("Unknown: " <> inspect(data))
    nil
  end

  def encode(nil), do: ["~#'", nil]
  def encode(%Types.UUID{value: uuid}), do: ["~#'", "~u" <> uuid]
  def encode(%Types.Symbol{value: sym}), do: ["~#'", "~$" <> sym]
  def encode(%Types.List{value: list}), do: encode_list(list)
  def encode(value) when is_boolean(value), do: ["~#'", value]
  def encode(data) when is_binary(data), do: ["~#'", data]
  def encode(data) when is_number(data), do: ["~#'", data]
  def encode(data) when is_atom(data), do: ["~#'", "~:" <> Atom.to_string(data)]

  def encode(data) do
    encode_item(data)
  end
end
