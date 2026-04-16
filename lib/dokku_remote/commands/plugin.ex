defmodule DokkuRemote.Commands.Plugin do
  @command_impl Application.compile_env(
                  :dokku_remote,
                  :"DokkuRemote.Dokku.Command",
                  DokkuRemote.Dokku.Command
                )

  @spec list(String.t()) :: {:ok, [__MODULE__.Entry.t()]} | {:error, any(), any()}
  @callback list(String.t()) :: {:ok, [__MODULE__.Entry.t()]} | {:error, any(), any()}
  def list(dokku_host) do
    case @command_impl.run(dokku_host, "plugin:list") do
      {:ok, output} -> {:ok, parse(output)}
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  defp parse(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_line/1)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_line(line) do
    case Regex.run(~r/^(\S+)\s+(\S+)\s+(enabled|disabled)\s+(.+)$/, line) do
      [_, name, version, status, description] ->
        %__MODULE__.Entry{
          name: name,
          version: version,
          enabled: status == "enabled",
          description: String.trim(description)
        }

      _ ->
        nil
    end
  end
end
