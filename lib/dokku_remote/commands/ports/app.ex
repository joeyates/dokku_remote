defmodule DokkuRemote.Commands.Ports.App do
  alias DokkuRemote.AppCommand

  @app_command_impl Application.compile_env(
                      :dokku_remote,
                      :"DokkuRemote.AppCommand",
                      DokkuRemote.AppCommand
                    )

  def get_prococol_mapping(%AppCommand{} = app, "http") do
    with {:ok, output} <- @app_command_impl.run(app, "ports:list", [app.dokku_app]),
         {:ok, host_port, container_port} <- extract_port_mapping(output, "http") do
      {:ok, host_port, container_port}
    end
  end

  def set_protocol_mapping(%AppCommand{} = app, "http", port) do
    case @app_command_impl.run(app, "ports:set", [app.dokku_app, "http:80:#{port}"]) do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  defp extract_port_mapping(output, protocol) do
    case Regex.run(~r/^\s+#{protocol}\s+(\d+)\s+(\d+)\s+$/m, output, capture: :all_but_first) do
      [host_port, container_port] ->
        {:ok, String.to_integer(host_port), String.to_integer(container_port)}

      _ ->
        {:error, :not_set}
    end
  end
end
