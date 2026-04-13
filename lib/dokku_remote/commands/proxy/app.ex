defmodule DokkuRemote.Commands.Proxy.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def disable(%AppCommand{} = app) do
    case @app_command_impl.run(app, "proxy:disable #{app.dokku_app}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
