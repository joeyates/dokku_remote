defmodule DokkuRemote.Commands.Logs.App do
  alias DokkuRemote.App

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.Dokku.Command.App",
                      DokkuRemote.Dokku.Command.App
                    )

  def get(%App{} = app, opts \\ []) do
    flags =
      []
      |> maybe_add_flag(opts[:n], fn n -> ["--num", to_string(n)] end)
      |> maybe_add_flag(opts[:tail], fn _ -> ["--tail"] end)
      |> maybe_add_flag(opts[:process_type], fn pt -> ["--ps", pt] end)

    @app_command_impl.run(app, "logs", [app.dokku_app | flags])
  end

  defp maybe_add_flag(acc, nil, _builder), do: acc
  defp maybe_add_flag(acc, false, _builder), do: acc
  defp maybe_add_flag(acc, value, builder), do: acc ++ builder.(value)
end
