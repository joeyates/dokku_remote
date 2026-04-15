defmodule DokkuRemote.Commands.Network.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def report(%App{} = app) do
    @app_command_impl.run(app, "network:report", [app.dokku_app])
  end

  def get(%App{} = app, network, property) do
    case @app_command_impl.run(
           app,
           "network:report",
           [app.dokku_app, network, "--network-#{property}"]
         ) do
      {:ok, output} ->
        value = String.trim(output)
        {:ok, value}

      {:error, output, exit} ->
        {:error, output, exit}
    end
  end

  def set(%App{} = app, property, value) do
    case @app_command_impl.run(app, "network:set", [app.dokku_app, property, value]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
