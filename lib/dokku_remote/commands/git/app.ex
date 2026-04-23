defmodule DokkuRemote.Commands.Git.App do
  alias DokkuRemote.App
  alias DokkuRemote.Commands.Git.Report

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def from_image(%App{} = app, image) do
    case @app_command_impl.run(app, "git:from-image", [image]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  @callback report(App.t()) :: {:ok, Report.t()} | {:error, any(), any()}
  def report(%App{} = app) do
    case @app_command_impl.run(app, "git:report") do
      {:ok, output} -> Report.from_output(output)
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end
end
