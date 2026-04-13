defmodule DokkuRemote.MixProject do
  use Mix.Project

  def project do
    [
      app: :dokku_remote,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:collectable_streamer, "~> 0.2.1"}
    ]
  end
end
