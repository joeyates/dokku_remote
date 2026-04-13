defmodule DokkuRemote.Commands.Enter do
  alias DokkuRemote.AppCommand

  # NOTE: The `enter` Dokku command allocates an interactive pseudo-TTY. The
  # underlying `AppCommand.run/2` collects output and waits for process exit,
  # so it cannot support a live interactive shell session. This implementation
  # is suitable for non-interactive / scripted invocations only (e.g. passing a
  # command via `enter APP PROCESS_TYPE -- CMD`). For full interactive use you
  # would need to exec the SSH process directly without capturing its I/O.

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def run(%AppCommand{} = app) do
    case @app_command_impl.run(app, "enter #{app.dokku_app}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
