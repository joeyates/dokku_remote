defmodule DokkuRemote.Commands.Ps.Report do
  @moduledoc """
  For now, we are skipping the "Status PROCESS INDEX: ..." lines
  """
  @keys [
    :app_name,
    :computed_stop_timeout_seconds,
    :deployed,
    :global_stop_timeout_seconds,
    :processes,
    :ps_can_scale,
    :ps_computed_procfile_path,
    :ps_global_procfile_path,
    :ps_procfile_path,
    :ps_restart_policy,
    :restore,
    :running,
    :stop_timeout_seconds
  ]
  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          app_name: String.t(),
          computed_stop_timeout_seconds: non_neg_integer(),
          deployed: boolean(),
          global_stop_timeout_seconds: non_neg_integer(),
          processes: non_neg_integer(),
          ps_can_scale: boolean(),
          ps_computed_procfile_path: String.t() | nil,
          ps_global_procfile_path: String.t() | nil,
          ps_procfile_path: String.t() | nil,
          ps_restart_policy: String.t() | nil,
          restore: boolean(),
          running: boolean(),
          stop_timeout_seconds: non_neg_integer()
        }

  @spec from_all_output(String.t()) :: {:ok, %{String.t() => t()}} | {:error, any()}
  def from_all_output(output) do
    output
    |> String.split(
      ~r/(?======> [\w\-]+ ps information)/,
      trim: true
    )
    |> Enum.map(&from_output/1)
    |> Enum.map(fn
      {:ok, report} -> {report.app_name, report}
    end)
    |> Enum.into(%{})
    |> then(&{:ok, &1})
  end

  def from_output(output) do
    app_data =
      output
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reduce(%{}, &parse_line/2)

    {:ok, struct!(__MODULE__, app_data)}
  end

  defp parse_line("=====> " <> rest, _app_data) do
    app_name = rest |> String.trim() |> String.replace(" ps information", "")

    %{
      app_name: String.trim(app_name),
      computed_stop_timeout_seconds: nil,
      deployed: nil,
      global_stop_timeout_seconds: nil,
      processes: nil,
      ps_can_scale: nil,
      ps_computed_procfile_path: nil,
      ps_global_procfile_path: nil,
      ps_procfile_path: nil,
      ps_restart_policy: nil,
      restore: nil,
      running: nil,
      stop_timeout_seconds: nil
    }
  end

  defp parse_line("Computed stop timeout seconds: " <> value, app_data) do
    %{app_data | computed_stop_timeout_seconds: value |> String.trim() |> String.to_integer()}
  end

  defp parse_line("Deployed: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | deployed: value == "true"}
  end

  defp parse_line("Global stop timeout seconds: " <> value, app_data) do
    %{app_data | global_stop_timeout_seconds: value |> String.trim() |> String.to_integer()}
  end

  defp parse_line("Processes: " <> value, app_data) do
    %{app_data | processes: value |> String.trim() |> String.to_integer()}
  end

  defp parse_line("Ps can scale: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | ps_can_scale: value == "true"}
  end

  defp parse_line("Ps computed procfile path: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | ps_computed_procfile_path: if(value == "", do: nil, else: value)}
  end

  defp parse_line("Ps global procfile path: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | ps_global_procfile_path: if(value == "", do: nil, else: value)}
  end

  defp parse_line("Ps procfile path: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | ps_procfile_path: if(value == "", do: nil, else: value)}
  end

  defp parse_line("Ps restart policy: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | ps_restart_policy: if(value == "", do: nil, else: value)}
  end

  defp parse_line("Restore: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | restore: value == "true"}
  end

  defp parse_line("Running: " <> value, app_data) do
    value = String.trim(value)
    %{app_data | running: value == "true"}
  end

  defp parse_line("Stop timeout seconds: " <> value, app_data) do
    %{app_data | stop_timeout_seconds: value |> String.trim() |> String.to_integer()}
  end

  defp parse_line(_line, app_data), do: app_data
end
