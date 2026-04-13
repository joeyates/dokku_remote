defmodule DokkuRemote.Commands.Git.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def from_image(%AppCommand{} = app, image) do
    case @app_command_impl.run(app, "git:from-image #{app.dokku_app} #{image}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
