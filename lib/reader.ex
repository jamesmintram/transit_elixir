defmodule TransitElixir.Reader do
  alias TransitElixir.Decode

  @spec from_json_data(any) :: any
  def from_json_data(data) do
    Decode.decode(data)
  end

  @spec from_string!(binary) :: any
  def from_string!(str) do
    str |> Jason.decode!() |> from_json_data()
  end

  @spec from_file!(binary) :: any
  def from_file!(path) do
    File.read!(path) |> from_string!()
  end
end
