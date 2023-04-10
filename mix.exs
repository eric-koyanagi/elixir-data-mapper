defmodule DM.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_data_mapper,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exshopify, "~> 0.9"},
      {:hackney, "~> 1.15"},
      {:jason, "~> 1.1"},
      {:gen_stage, "~> 0.14"},
      {:neuron, "~> 5.1.0"},
      {:csv, "~> 3.0"},
      {:shopify_graphql, "~> 2.1.0"}
    ]
  end
end
