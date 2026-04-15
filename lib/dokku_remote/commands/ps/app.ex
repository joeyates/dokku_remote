defmodule DokkuRemote.Commands.Ps.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def rebuild(%AppCommand{} = app) do
    case @app_command_impl.run(app, "ps:rebuild", [app.dokku_app]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def report(%AppCommand{} = app) do
    @app_command_impl.run(app, "ps:report", [app.dokku_app])
  end

  def restart(%AppCommand{} = app) do
    case @app_command_impl.run(app, "ps:restart", [app.dokku_app]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def stop(%AppCommand{} = app) do
    case @app_command_impl.run(app, "ps:stop", [app.dokku_app]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
