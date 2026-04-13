defmodule DokkuRemote.Commands.Ports.App do
  alias DokkuRemote.AppCommand

  def set_80(%AppCommand{} = app, port) do
    case AppCommand.run(app, "ports:set #{app.dokku_app} http:80:#{port}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
