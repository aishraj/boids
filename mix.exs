defmodule Boids.Mixfile do
  use Mix.Project

  def project do
    [
      app: :boids,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Boids, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:wobserver, "~> 0.1"}
    ]
  end
end
