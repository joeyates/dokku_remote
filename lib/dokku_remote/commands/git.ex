defmodule DokkuRemote.Commands.Git do
  @command_impl Application.compile_env(
                  :dokku_remote,
                  :"DokkuRemote.Dokku.Command",
                  DokkuRemote.Dokku.Command
                )

  @type reports :: %{String.t() => __MODULE__.Report.t()}

  @callback report(String.t()) :: {:ok, reports()} | {:error, any(), any()}

  @spec report(String.t()) :: {:ok, reports()} | {:error, any(), any()}
  @doc """
  Retrieves the git deployment report for all applications on the specified Dokku host.
  """
  def report(dokku_host) do
    case @command_impl.run(dokku_host, "git:report") do
      {:ok, output} -> {:ok, parse(output)}
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  defp parse(output) do
    app_data = nil
    reports = %{}

    output
    |> String.split("\n", trim: true)
    |> Enum.reduce({app_data, reports}, &parse_line/2)
    |> maybe_save_report()
  end

  defp parse_line("=====> " <> rest, {app_data, acc}) do
    acc = maybe_save_report({app_data, acc})

    app_name = rest |> String.split(" ") |> List.first()
    {%{app_name: app_name}, acc}
  end

  defp parse_line("Git deploy branch: " <> rest, {app_data, acc}) when is_map(app_data) do
    entry = String.trim(rest)
    app_data = Map.put(app_data, :deploy_branch, entry)
    {app_data, acc}
  end

  defp parse_line("Git global deploy branch: " <> rest, {app_data, acc}) when is_map(app_data) do
    entry = String.trim(rest)
    app_data = Map.put(app_data, :global_deploy_branch, entry)
    {app_data, acc}
  end

  defp parse_line("Git keep git dir: " <> rest, {app_data, acc}) when is_map(app_data) do
    entry = String.trim(rest)
    app_data = Map.put(app_data, :keep_git_dir, entry == "true")
    {app_data, acc}
  end

  defp parse_line("Git rev env var: " <> rest, {app_data, acc}) when is_map(app_data) do
    entry = String.trim(rest)
    app_data = Map.put(app_data, :rev_env_var, entry)
    {app_data, acc}
  end

  defp parse_line("Git sha: " <> rest, {app_data, acc}) when is_map(app_data) do
    entry = String.trim(rest)
    app_data = Map.put(app_data, :sha, entry)
    {app_data, acc}
  end

  defp parse_line("Git source image:" <> rest, {app_data, acc}) when is_map(app_data) do
    entry = String.trim(rest)
    app_data = Map.put(app_data, :source_image, entry)
    {app_data, acc}
  end

  defp parse_line("Git last updated at: " <> rest, {app_data, acc}) when is_map(app_data) do
    entry = String.trim(rest)
    app_data = Map.put(app_data, :last_updated_at, String.to_integer(entry))
    {app_data, acc}
  end

  defp parse_line(_line, {any, acc}), do: {any, acc}

  defp maybe_save_report({nil, acc}), do: acc

  defp maybe_save_report({app_data, acc}) do
    report = struct!(__MODULE__.Report, app_data)
    Map.put(acc, report.app_name, report)
  end
end
