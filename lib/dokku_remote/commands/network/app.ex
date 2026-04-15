defmodule DokkuRemote.Commands.Network.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def report(%AppCommand{} = app) do
    @app_command_impl.run(app, "network:report", [app.dokku_app])
  end

  def get(%AppCommand{} = app, network, property) do
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

  def set(%AppCommand{} = app, property, value) do
    case @app_command_impl.run(app, "network:set", [app.dokku_app, property, value]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
