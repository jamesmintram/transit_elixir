defmodule TransitElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :transit_elixir,
      version: "0.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/jamesmintram/transit_elixir"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.1"}
    ]
  end

  defp description do
    """
    Elixir library for working with the transit data format
    """
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w(lib config priv .formatter.exs mix.exs README* LICENSE*),
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/jamesmintram/transit_elixir"}
    ]
  end
end
