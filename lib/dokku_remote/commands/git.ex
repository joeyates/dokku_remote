defmodule DokkuRemote.Commands.Git do
  alias __MODULE__.Report

  @command_impl Application.compile_env(
                  :dokku_remote,
                  :"DokkuRemote.Dokku.Command",
                  DokkuRemote.Dokku.Command
                )

  @type reports :: %{String.t() => Report.t()}

  @doc """
  Retrieves the git deployment report for all applications on the specified Dokku host.
  """
  @callback report(String.t()) :: {:ok, reports()} | {:error, any(), any()}
  def report(dokku_host) do
    case @command_impl.run(dokku_host, "git:report") do
      {:ok, output} -> parse(output)
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  defp parse(output) do
    output
    |> String.split(
      ~r/(?======> [\w\-]+ git information)/,
      trim: true
    )
    |> Enum.map(&Report.from_output/1)
    |> Enum.map(fn
      {:ok, report} -> {report.app_name, report}
    end)
    |> Enum.into(%{})
    |> then(&{:ok, &1})
  end
end
