defmodule DokkuRemote.Commands.Logs.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def get(%AppCommand{} = app, opts \\ []) do
    flags =
      []
      |> maybe_add_flag(opts[:n], fn n -> "--num #{n}" end)
      |> maybe_add_flag(opts[:tail], fn _ -> "--tail" end)
      |> maybe_add_flag(opts[:process_type], fn pt -> "--ps #{pt}" end)

    flag_string = if flags == [], do: "", else: " " <> Enum.join(flags, " ")
    command = "logs #{app.dokku_app}#{flag_string}"

    @app_command_impl.run(app, command)
  end

  defp maybe_add_flag(acc, nil, _builder), do: acc
  defp maybe_add_flag(acc, false, _builder), do: acc
  defp maybe_add_flag(acc, value, builder), do: acc ++ [builder.(value)]
end
