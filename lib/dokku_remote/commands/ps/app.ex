defmodule DokkuRemote.Commands.Ps.App do
  alias DokkuRemote.App
  alias DokkuRemote.Commands.Ps.Report
  alias DokkuRemote.Commands.Ps.Scale

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

  @callback report(App.t()) :: {:ok, Report.t()} | {:error, any(), any()}
  def report(%App{} = app) do
    case @app_command_impl.run(app, "ps:report") do
      {:ok, output} -> Report.from_output(output)
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  def restart(%App{} = app) do
    case @app_command_impl.run(app, "ps:restart") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  @callback scale(App.t()) :: {:ok, Scale.t()} | {:error, any(), any()}
  def scale(%App{} = app) do
    case @app_command_impl.run(app, "ps:scale") do
      {:ok, output} -> Scale.from_output(output)
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  def stop(%App{} = app) do
    case @app_command_impl.run(app, "ps:stop") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
