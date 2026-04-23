defmodule DokkuRemote.Commands.Git.Report do
  @required_keys [
    :app_name,
    :deploy_branch,
    :global_deploy_branch,
    :keep_git_dir,
    :rev_env_var
  ]
  @optional_keys [
    :sha,
    :source_image,
    :last_updated_at
  ]
  @enforce_keys @required_keys
  defstruct @required_keys ++ Enum.map(@optional_keys, &{&1, nil})

  @type t :: %__MODULE__{
          app_name: String.t(),
          deploy_branch: String.t(),
          global_deploy_branch: String.t(),
          keep_git_dir: boolean(),
          rev_env_var: String.t(),
          sha: String.t(),
          source_image: String.t(),
          last_updated_at: non_neg_integer()
        }

  def from_output(output) do
    app_data =
      output
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reduce(%{}, &parse_line/2)

    {:ok, struct!(__MODULE__, app_data)}
  end

  defp parse_line("=====> " <> rest, _app_data) do
    app_name =
      rest
      |> String.trim()
      |> String.replace(" git information", "")

    %{app_name: app_name}
  end

  defp parse_line("Git deploy branch: " <> rest, app_data) do
    entry = String.trim(rest)
    Map.put(app_data, :deploy_branch, entry)
  end

  defp parse_line("Git global deploy branch: " <> rest, app_data) do
    entry = String.trim(rest)
    Map.put(app_data, :global_deploy_branch, entry)
  end

  defp parse_line("Git keep git dir: " <> rest, app_data) do
    entry = String.trim(rest)
    Map.put(app_data, :keep_git_dir, entry == "true")
  end

  defp parse_line("Git rev env var: " <> rest, app_data) do
    entry = String.trim(rest)
    Map.put(app_data, :rev_env_var, entry)
  end

  defp parse_line("Git sha: " <> rest, app_data) do
    entry = String.trim(rest)
    Map.put(app_data, :sha, entry)
  end

  defp parse_line("Git source image:" <> rest, app_data) do
    value = String.trim(rest)
    entry = if value == "", do: nil, else: value
    Map.put(app_data, :source_image, entry)
  end

  defp parse_line("Git last updated at: " <> rest, app_data) do
    entry = String.trim(rest)
    Map.put(app_data, :last_updated_at, String.to_integer(entry))
  end

  defp parse_line(_line, {any, acc}), do: {any, acc}
end
