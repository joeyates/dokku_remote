defmodule DokkuRemote.Commands.Ps do
  @command_impl Application.compile_env(
                  :dokku_remote,
                  :"DokkuRemote.Dokku.Command",
                  DokkuRemote.Dokku.Command
                )

  @type scales :: %{String.t() => __MODULE__.Scale.t()}

  @spec scale(String.t()) :: {:ok, scales()} | {:error, any(), any()}
  def scale(dokku_host) do
    case @command_impl.run(dokku_host, "ps:scale", []) do
      {:ok, output} -> {:ok, parse_all(output)}
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  @spec scale(String.t(), String.t()) :: {:ok, __MODULE__.Scale.t()} | {:error, any(), any()}
  def scale(dokku_host, app_name) do
    case @command_impl.run(dokku_host, "ps:scale", [app_name]) do
      {:ok, output} -> {:ok, parse_one(output, app_name)}
      {:error, output, exit_code} -> {:error, output, exit_code}
    end
  end

  defp parse_all(output) do
    app_data = nil
    scales = %{}

    output
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce({app_data, scales}, &parse_line/2)
    |> maybe_save_scale()
  end

  defp parse_one(output, app_name) do
    scales = parse_all(output)
    scales[app_name]
  end

  defp parse_line("-----> Scaling for " <> app_name, {app_data, acc}) do
    acc = maybe_save_scale({app_data, acc})
    {%{app_name: String.trim(app_name), proctypes: %{}}, acc}
  end

  defp parse_line(line, {app_data, acc}) when is_map(app_data) do
    case Regex.run(~r/^(\w+):\s+(\d+)$/, line) do
      [_, proctype, qty] ->
        proctypes = Map.put(app_data.proctypes, proctype, String.to_integer(qty))
        {%{app_data | proctypes: proctypes}, acc}

      _ ->
        {app_data, acc}
    end
  end

  defp parse_line(_line, {any, acc}), do: {any, acc}

  defp maybe_save_scale({nil, acc}), do: acc

  defp maybe_save_scale({app_data, acc}) do
    scale = struct!(__MODULE__.Scale, app_data)
    Map.put(acc, scale.app_name, scale)
  end
end
