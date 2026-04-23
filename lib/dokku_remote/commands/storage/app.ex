defmodule DokkuRemote.Commands.Storage.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def ensure_directory(%App{} = app) do
    case @app_command_impl.run(app, "storage:ensure-directory") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  @callback mount_exists?(App.t(), String.t(), String.t()) ::
              {:ok, boolean()} | {:error, any(), any()}
  def mount_exists?(%App{} = app, host_dir, container_dir) do
    case @app_command_impl.run(app, "storage:report", ["--storage-run-mounts"]) do
      {:ok, output} ->
        mount = mount_param(host_dir, container_dir)

        if String.contains?(output, mount) do
          {:ok, true}
        else
          {:ok, false}
        end

      {:error, output, exit} ->
        {:error, output, exit}
    end
  end

  def mount(%App{} = app, host_dir, container_dir) do
    param = mount_param(host_dir, container_dir)

    case @app_command_impl.run(app, "storage:mount", [param]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  defp mount_param(host_dir, container_dir), do: "#{host_dir}:#{container_dir}"
end
