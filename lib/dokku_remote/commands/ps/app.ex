defmodule DokkuRemote.Commands.Ps.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def rebuild(%App{} = app) do
    case @app_command_impl.run(app, "ps:rebuild") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def report(%App{} = app) do
    @app_command_impl.run(app, "ps:report")
  end

  def restart(%App{} = app) do
    case @app_command_impl.run(app, "ps:restart") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def stop(%App{} = app) do
    case @app_command_impl.run(app, "ps:stop") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
