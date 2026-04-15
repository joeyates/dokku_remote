defmodule DokkuRemote.Commands.DockerOptions.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def exists?(%AppCommand{} = app, phase, option) do
    case @app_command_impl.run(app, "docker-options:report #{app.dokku_app}") do
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

  def add(%AppCommand{} = app, phase, option) do
    case @app_command_impl.run(app, "docker-options:add #{app.dokku_app} #{phase} #{option}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
