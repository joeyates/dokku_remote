defmodule DokkuRemote.Commands.Domains.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def get(%AppCommand{} = app) do
    with {:ok, output} <- @app_command_impl.run(app, "domains:report #{app.dokku_app}"),
         true <- String.match?(output, ~r/Domains app enabled:\s+true/),
         [domain] <- Regex.run(~r<Domains app vhosts:\s+(.*)>, output, capture: :all_but_first) do
      {:ok, domain}
    else
      {:error, output, exit} ->
        {:error, output, exit}

      _any ->
        {:ok, nil}
    end
  end

  def set(%AppCommand{} = app, domain) do
    case @app_command_impl.run(app, "domains:set #{app.dokku_app} #{domain}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
