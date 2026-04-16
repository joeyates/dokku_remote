defmodule DokkuRemote.Commands.Certs do
  @command_impl Application.compile_env(
                  :dokku_remote,
                  :"DokkuRemote.Dokku.Command",
                  DokkuRemote.Dokku.Command
                )

  @type reports :: %{String.t() => __MODULE__.Report.t()}

  @callback report(String.t()) :: {:ok, reports()} | {:error, any(), any()}

  @spec report(String.t()) :: {:ok, reports()} | {:error, any(), any()}
  def report(dokku_host) do
    case @command_impl.run(dokku_host, "certs:report") do
      {:ok, output} -> {:ok, parse(output)}
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  defp parse(output) do
    app_data = nil
    reports = %{}

    output
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce({app_data, reports}, &parse_line/2)
    |> maybe_save_report()
  end

  defp parse_line("=====> " <> rest, {app_data, acc}) do
    acc = maybe_save_report({app_data, acc})

    app_name = rest |> String.split(" ") |> List.first()
    {%{app_name: app_name}, acc}
  end

  defp parse_line("Ssl dir: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :dir, String.trim(rest))
    {app_data, acc}
  end

  defp parse_line("Ssl enabled: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :enabled, String.trim(rest) == "true")
    {app_data, acc}
  end

  defp parse_line("Ssl hostnames: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :hostnames, String.trim(rest))
    {app_data, acc}
  end

  defp parse_line("Ssl expires at: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :expires_at, String.trim(rest))
    {app_data, acc}
  end

  defp parse_line("Ssl issuer: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :issuer, String.trim(rest))
    {app_data, acc}
  end

  defp parse_line("Ssl starts at: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :starts_at, String.trim(rest))
    {app_data, acc}
  end

  defp parse_line("Ssl subject: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :subject, String.trim(rest))
    {app_data, acc}
  end

  defp parse_line("Ssl verified: " <> rest, {app_data, acc}) when is_map(app_data) do
    app_data = Map.put(app_data, :verified, String.trim(rest))
    {app_data, acc}
  end

  defp parse_line(_line, {any, acc}), do: {any, acc}

  defp maybe_save_report({nil, acc}), do: acc

  defp maybe_save_report({app_data, acc}) do
    report = struct!(__MODULE__.Report, app_data)
    Map.put(acc, report.app_name, report)
  end
end
