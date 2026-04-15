defmodule DokkuRemote.Commands.Network do
  @command_impl Application.compile_env(
                  :dokku_remote,
                  :"DokkuRemote.Dokku.Command",
                  DokkuRemote.Dokku.Command
                )

  def create(dokku_host, network) do
    case @command_impl.run(dokku_host, "network:create #{network}") do
      {:ok, _output} -> :ok
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  def exists?(dokku_host, network) do
    with {:ok, output} <- @command_impl.run(dokku_host, "network:exists #{network}"),
         {:ok, exists} <- parse_exists_output(output) do
      {:ok, exists}
    else
      {:error, output, exit} -> {:error, output, exit}
    end
  end

  defp parse_exists_output(output) do
    cond do
      String.match?(output, ~r/\bexists\b/) -> {:ok, true}
      String.match?(output, ~r/\bdoes not exist\b/) -> {:ok, false}
      true -> {:error, "Unexpected output: #{output}", -1}
    end
  end
end
