defmodule DokkuRemote.Commands.DockerOptions.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def exists?(%App{} = app, phase, option) do
    case @app_command_impl.run(app, "docker-options:report", [app.dokku_app]) do
      {:ok, output} ->
        if has_option?(output, phase, option) do
          {:ok, true}
        else
          {:ok, false}
        end

      {:error, output, exit} ->
        {:error, output, exit}
    end
  end

  defp has_option?(output, phase, option) do
    output
    |> String.split("\n")
    |> Enum.find_value(false, fn line ->
      if String.contains?(line, "Docker options #{phase}:") do
        line
        |> String.replace("Docker options #{phase}:", "")
        |> String.trim()
        |> String.contains?(option)
      end
    end)
  end

  def add(%App{} = app, phase, option) do
    case @app_command_impl.run(app, "docker-options:add", [app.dokku_app, phase, option]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
