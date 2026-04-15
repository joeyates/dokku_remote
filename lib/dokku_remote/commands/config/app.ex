defmodule DokkuRemote.Commands.Config.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def set(%AppCommand{} = app, key, value, opts \\ []) do
    restart = opts[:restart]
    flags = if restart, do: [], else: ["--no-restart"]

    case @app_command_impl.run(app, "config:set", flags ++ [app.dokku_app, "#{key}=#{value}"]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def unset(%AppCommand{} = app, key, opts \\ []) do
    restart = opts[:restart]
    flags = if restart, do: [], else: ["--no-restart"]

    case @app_command_impl.run(app, "config:unset", flags ++ [app.dokku_app, key]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
