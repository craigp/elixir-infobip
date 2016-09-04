defmodule Infobip.Mixfile do
  use Mix.Project

  def project do
    [app: :infobip,
     version: "0.0.10",
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     description: "A simple Infobip REST API client for Elixir",
     package: package]
  end

  def application do
    [applications: [:logger, :httpoison, :xml_builder, :erlsom],
     mod: {Infobip, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:xml_builder, "~> 0.0.8"},
      {:erlsom, github: "willemdj/erlsom"},
      {:excoveralls, "~> 0.5.5", only: :test},
      {:earmark, "~> 1.0.1", only: :dev},
      {:ex_doc, "~> 0.13.0", only: :dev},
      {:dialyxir, "~> 0.3.5", only: :dev},
      {:credo, "~> 0.4.8", only: :dev},
      {:bypass, "~> 0.5.1", only: :test},
      {:inch_ex, "~> 0.5.3", only: :docs}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["MIT"],
      maintainers: ["Craig Paterson"],
      links: %{"Github" => "https://github.com/craigp/elixir-infobip"}
    ]
  end
end
