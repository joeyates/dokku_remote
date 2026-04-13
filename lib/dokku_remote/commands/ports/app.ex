defmodule DokkuRemote.Commands.Ports.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def set_80(%AppCommand{} = app, port) do
    case @app_command_impl.run(app, "ports:set #{app.dokku_app} http:80:#{port}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
