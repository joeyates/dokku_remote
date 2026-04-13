defmodule DokkuRemote.Commands.Config.App do
  alias DokkuRemote.AppCommand

  def set(%AppCommand{} = app, key, value, opts \\ []) do
    restart = opts[:restart]
    do_resart = if restart, do: "", else: "--no-restart "
    command = "config:set #{do_resart} #{app.dokku_app} #{key}=#{value}"

    case AppCommand.run(app, command) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def unset(%AppCommand{} = app, key, opts \\ []) do
    restart = opts[:restart]
    do_resart = if restart, do: "", else: "--no-restart "
    command = "config:unset #{do_resart} #{app.dokku_app} #{key}"

    case AppCommand.run(app, command) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
