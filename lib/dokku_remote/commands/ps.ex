defmodule DokkuRemote.Commands.Ps do
  alias DokkuRemote.Commands.Ps.Report
  alias DokkuRemote.Commands.Ps.Scale

  @dokku_command_impl Application.compile_env(
                        :dokku_remote,
                        :"DokkuRemote.Dokku.Command",
                        DokkuRemote.Dokku.Command
                      )

  @callback report(String.t()) :: {:ok, [Report.t()]} | {:error, any(), any()}
  def report(dokku_host) do
    case @dokku_command_impl.run(dokku_host, "ps:report") do
      {:ok, output} -> Report.from_all_output(output)
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  @callback scale(String.t()) :: {:ok, [Scale.t()]} | {:error, any(), any()}
  def scale(dokku_host) do
    case @dokku_command_impl.run(dokku_host, "ps:scale", []) do
      {:ok, output} -> Scale.from_all_output(output)
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end
end
