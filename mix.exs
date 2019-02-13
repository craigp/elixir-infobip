defmodule Infobip.Mixfile do
  use Mix.Project

  def project do
    [app: :infobip,
     version: "0.1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test
      ],
     description: "A simple Infobip REST API client for Elixir",
     package: package()]
  end

  def application do
    [extra_applications: [:logger, :httpoison, :xml_builder, :erlsom]]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:xml_builder, "~> 2.1"},
      {:erlsom, "~> 1.4"},
      {:excoveralls, "~> 0.5", only: :test},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.13", only: :dev},
      {:dialyxir, "~> 0.3", only: :dev},
      {:credo, "~> 1.0", only: :dev},
      {:bypass, "~> 1.0", only: :test},
      {:dogma, "~> 0.1", only: :dev},
      {:inch_ex, "~> 2.0", only: :docs}
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
