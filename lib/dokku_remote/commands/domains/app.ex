defmodule DokkuRemote.Commands.Domains.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def get(%App{} = app) do
    with {:ok, output} <- @app_command_impl.run(app, "domains:report"),
         true <- String.match?(output, ~r/Domains app enabled:\s+true/),
         [domain] <-
           Regex.run(~r<Domains app vhosts:\s+([\w\.-]*)>, output, capture: :all_but_first) do
      {:ok, domain}
    else
      {:error, output, exit} ->
        {:error, output, exit}

      _any ->
        {:ok, nil}
    end
  end

  def set(%App{} = app, domain) do
    case @app_command_impl.run(app, "domains:set", [domain]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end
end
