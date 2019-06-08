defmodule Sled.MixProject do
  use Mix.Project

  def project do
    [
      app: :sled_ex,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      compilers: [:rustler] ++ Mix.compilers(),
      deps: deps(),
      rustler_crates: [
        sled_ex: [
          mode: (if Mix.env() == :prod, do: :release, else: :debug)
        ]
      ],
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
      {:rustler, "~> 0.20.0"}
    ]
  end
end
