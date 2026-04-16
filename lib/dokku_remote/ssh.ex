defmodule DokkuRemote.Ssh do
  @system_impl Application.compile_env(:dokku_remote, :System, System)

  @callback run(
              dokku_host :: String.t(),
              user :: String.t(),
              command :: String.t()
            ) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(
              dokku_host :: String.t(),
              user :: String.t(),
              command :: String.t(),
              params :: [String.t()]
            ) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(
              dokku_host :: String.t(),
              user :: String.t(),
              command :: String.t(),
              params :: [String.t()],
              opts :: Keyword.t()
            ) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}

  def run(dokku_host, user, command, params \\ [], opts \\ []) do
    verbose = Keyword.get(opts, :verbose, false)

    into =
      if verbose do
        CollectableStreamer.new(fn line -> IO.write(line) end)
      else
        ""
      end

    args = build_args(dokku_host, user, command, params)

    if verbose do
      IO.puts("Running command as root: ssh #{Enum.join(args, " ")}")
    end

    case @system_impl.cmd("ssh", args, stderr_to_stdout: true, into: into) do
      {output, 0} ->
        {:ok, output}

      {output, exit} ->
        {:error, output, exit}
    end
  end

  defp build_args(dokku_host, user, command, params) do
    ssh_args(dokku_host, user) ++
      ["#{user}@#{dokku_host}", command] ++
      params
  end

  defp ssh_args(dokku_host, user) do
    get_in(module_env(), [dokku_host, user]) || []
  end

  defp module_env() do
    env = Application.get_env(:dokku_remote, __MODULE__, %{})

    if not is_map(env) do
      raise ArgumentError,
            "Expected #{inspect(__MODULE__)} configuration to be a map, got: #{inspect(env)}"
    end

    env
  end
end
