defmodule DokkuRemote.Commands.Letsencrypt.App do
  alias DokkuRemote.AppCommand

  def set(%AppCommand{} = app, key, value) do
    case AppCommand.run(app, "letsencrypt:set #{app.dokku_app} #{key} #{value}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def unset(%AppCommand{} = app, key) do
    case AppCommand.run(app, "letsencrypt:set #{app.dokku_app} #{key}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def enable(%AppCommand{} = app) do
    case AppCommand.run(app, "letsencrypt:enable #{app.dokku_app}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
