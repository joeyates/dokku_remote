defmodule DokkuRemote.Commands.Letsencrypt.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def set(%App{} = app, key, value) do
    case @app_command_impl.run(app, "letsencrypt:set", [key, value]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def unset(%App{} = app, key) do
    case @app_command_impl.run(app, "letsencrypt:set", [key]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def enable(%App{} = app) do
    case @app_command_impl.run(app, "letsencrypt:enable") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
