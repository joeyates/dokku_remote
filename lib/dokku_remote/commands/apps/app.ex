defmodule DokkuRemote.Commands.Apps.App do
  alias DokkuRemote.AppCommand

  def exists?(%AppCommand{} = app) do
    case AppCommand.run(app, "apps:exists #{app.dokku_app}") do
      {:ok, _output} -> true
      {:error, _output, 20} -> false
      {:error, output, exit} -> raise "Error checking if app exists, exit code #{exit}: #{output}"
    end
  end

  def running?(%AppCommand{} = app) do
    with {:ok, output} <- AppCommand.run(app, "ps:report #{app.dokku_app}"),
         [status] <- Regex.run(~r/Running:\s+(\w+)/, output, capture: :all_but_first) do
      status == "true"
    else
      {:error, output, exit} ->
        raise "Error checking if app is running, exit code #{exit}: #{output}"
    end
  end

  def create(%AppCommand{} = app) do
    case AppCommand.run(app, "apps:create #{app.dokku_app}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
