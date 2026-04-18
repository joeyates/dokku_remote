defmodule DokkuRemote.Commands.Enter.App do
  alias DokkuRemote.App

  # NOTE: The `enter` Dokku command allocates an interactive pseudo-TTY. The
  # the underlying `AppCommand.run/3` collects output and waits for process exit,
  # so it cannot support a live interactive shell session. This implementation
  # is suitable for non-interactive / scripted invocations only (e.g. passing a
  # command via `enter APP PROCESS_TYPE -- CMD`). For full interactive use you
  # would need to exec the SSH process directly without capturing its I/O.

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  @callback run(app :: App.t(), process :: String.t(), params :: [String.t()]) ::
              {:ok, output :: String.t()} | {:error, output :: String.t(), exit_code :: integer()}
  def run(%App{} = app, process, params) do
    case @app_command_impl.run(app, "enter", [process | params]) do
      {:ok, output} ->
        {:ok, output}

      {:error, output, exit} ->
        {:error, output, exit}
    end
  end
end
