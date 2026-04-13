defmodule DokkuRemote.Commands.DockerOptions.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def add(%AppCommand{} = app, phase, option) do
    case @app_command_impl.run(app, "docker-options:add #{app.dokku_app} #{phase} #{option}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
