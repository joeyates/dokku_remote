defmodule DokkuRemote.Commands.Proxy.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def enabled?(%App{} = app) do
    case @app_command_impl.run(app, "proxy:report", [app.dokku_app]) do
      {:ok, output} ->
        cond do
          String.match?(output, ~r/Proxy enabled:\s+true/) -> {:ok, true}
          String.match?(output, ~r/Proxy enabled:\s+false/) -> {:ok, false}
          true -> {:error, "Unexpected output: #{output}", -1}
        end

      {:error, output, exit} ->
        {:error, output, exit}
    end
  end

  def disable(%App{} = app) do
    case @app_command_impl.run(app, "proxy:disable", [app.dokku_app]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
