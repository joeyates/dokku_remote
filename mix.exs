defmodule DokkuRemote.MixProject do
  use Mix.Project

  @app :dokku_remote

  def project() do
    [
      app: @app,
      version: "0.3.3",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "An Elixir client library for running dokku commands on a remote host",
      package: package(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      config_path: "config/config.exs",
      deps: deps()
    ]
  end

  def application() do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps() do
    [
      {:collectable_streamer, "~> 0.2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:green, "~> 0.1.11", only: :dev},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp package() do
    %{
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/joeyates/dokku_remote"
      },
      maintainers: ["Joe Yates"]
    }
  end

  defp aliases() do
    [
      "check.format": "format --check-formatted",
      check: [
        "check.format",
        "cmd mix test"
      ]
    ]
  end
end
