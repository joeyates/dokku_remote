defmodule DokkuRemote.Commands.Network.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def report(%App{} = app) do
    @app_command_impl.run(app, "network:report")
  end

  @callback get(app :: App.t(), property :: String.t()) ::
              {:ok, value :: String.t()} | {:error, output :: String.t(), exit_code :: integer()}
  def get(%App{} = app, property) do
    case @app_command_impl.run(app, "network:report", ["--network-#{property}"]) do
      {:ok, output} ->
        value = String.trim(output)
        {:ok, value}

      {:error, output, exit} ->
        {:error, output, exit}
    end
  end

  def set(%App{} = app, property, value) do
    case @app_command_impl.run(app, "network:set", [property, value]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
