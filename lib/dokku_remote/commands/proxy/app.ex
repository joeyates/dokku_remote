defmodule DokkuRemote.Commands.Proxy.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def enabled?(%AppCommand{} = app) do
    case @app_command_impl.run(app, "proxy:report #{app.dokku_app}") do
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

  def disable(%AppCommand{} = app) do
    case @app_command_impl.run(app, "proxy:disable #{app.dokku_app}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
