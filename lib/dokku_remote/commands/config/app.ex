defmodule DokkuRemote.Commands.Config.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def set(%App{} = app, key, value, opts \\ []) do
    restart = opts[:restart]
    flags = if restart, do: [], else: ["--no-restart"]

    case @app_command_impl.run(app, "config:set", ["#{key}=#{value}"] ++ flags) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def unset(%App{} = app, key, opts \\ []) do
    restart = opts[:restart]
    flags = if restart, do: [], else: ["--no-restart"]

    case @app_command_impl.run(app, "config:unset", [key] ++ flags) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
