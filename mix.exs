defmodule Infobip.Mixfile do
  use Mix.Project

  def project do
    [app: :infobip,
     version: "0.0.1",
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     description: "A simple Infobip REST API client for Elixir",
     package: package]
  end

  def application do
    [applications: [:logger, :httpoison, :xml_builder],
     mod: {Infobip, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8"},
      {:xml_builder, "~> 0.0.8"},
      {:erlsom, github: "willemdj/erlsom"}
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
