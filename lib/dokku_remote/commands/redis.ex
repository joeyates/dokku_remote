defmodule DokkuRemote.Commands.Redis do
  @command_impl Application.compile_env(
                  :dokku_remote,
                  :"DokkuRemote.Dokku.Command",
                  DokkuRemote.Dokku.Command
                )

  @spec list(String.t()) :: {:ok, [String.t()]} | {:error, any(), any()}
  @callback list(String.t()) :: {:ok, [String.t()]} | {:error, any(), any()}
  def list(dokku_host) do
    case @command_impl.run(dokku_host, "redis:list") do
      {:ok, output} -> {:ok, parse_list(output)}
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  @spec links(String.t(), String.t()) :: {:ok, [String.t()]} | {:error, any(), any()}
  @callback links(String.t(), String.t()) :: {:ok, [String.t()]} | {:error, any(), any()}
  def links(dokku_host, service) do
    case @command_impl.run(dokku_host, "redis:links", [service]) do
      {:ok, output} -> {:ok, parse_lines(output)}
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  defp parse_list(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&String.starts_with?(&1, "=====>"))
    |> Enum.reject(&(&1 == ""))
  end

  defp parse_lines(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
