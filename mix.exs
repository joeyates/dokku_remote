defmodule DokkuRemote.MixProject do
  use Mix.Project

  def project() do
    [
      app: :dokku_remote,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      config_path: "config/config.exs",
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:collectable_streamer, "~> 0.2.1"},
      {:green, "~> 0.1.11", only: :dev},
      {:mox, "~> 1.0", only: :test}
    ]
  end
end
