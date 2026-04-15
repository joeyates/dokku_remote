defmodule DokkuRemote.Commands.Apps.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def exists?(%App{} = app) do
    case @app_command_impl.run(app, "apps:exists") do
      {:ok, _output} -> true
      {:error, _output, 20} -> false
      {:error, output, exit} -> raise "Error checking if app exists, exit code #{exit}: #{output}"
    end
  end

  def running?(%App{} = app) do
    with {:ok, output} <- @app_command_impl.run(app, "ps:report"),
         [status] <- Regex.run(~r/Running:\s+(\w+)/, output, capture: :all_but_first) do
      status == "true"
    else
      {:error, output, exit} ->
        raise "Error checking if app is running, exit code #{exit}: #{output}"
    end
  end

  def create(%App{} = app) do
    case @app_command_impl.run(app, "apps:create") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
