defmodule DokkuRemote.Commands.Storage.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def ensure_directory(%AppCommand{} = app, dir) do
    case @app_command_impl.run(app, "storage:ensure-directory #{app.dokku_app} #{dir}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def mount(%AppCommand{} = app, host_dir, container_dir) do
    case @app_command_impl.run(app, "storage:mount #{app.dokku_app} #{host_dir}:#{container_dir}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
