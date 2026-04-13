defmodule DokkuRemote.Commands.Letsencrypt.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def set(%AppCommand{} = app, key, value) do
    case @app_command_impl.run(app, "letsencrypt:set #{app.dokku_app} #{key} #{value}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def unset(%AppCommand{} = app, key) do
    case @app_command_impl.run(app, "letsencrypt:set #{app.dokku_app} #{key}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def enable(%AppCommand{} = app) do
    case @app_command_impl.run(app, "letsencrypt:enable #{app.dokku_app}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
