defmodule DokkuRemote.Command do
  @system_impl Application.compile_env(:dokku_remote, :System, System)

  @callback run(dokku_host :: String.t(), command :: String.t()) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(dokku_host :: String.t(), command :: String.t(), params :: [String.t()]) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(
              dokku_host :: String.t(),
              command :: String.t(),
              params :: [String.t()],
              opts :: Keyword.t()
            ) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}

  def run(dokku_host, command, params \\ [], opts \\ []) do
    verbose = Keyword.get(opts, :verbose, false)

    into =
      if verbose do
        CollectableStreamer.new(fn line -> IO.write(line) end)
      else
        ""
      end

    args = ["dokku@#{dokku_host}" | [command | params]]

    if verbose do
      IO.puts("Running command: ssh #{Enum.join(args, " ")}")
    end

    case @system_impl.cmd("ssh", args, stderr_to_stdout: true, into: into) do
      {output, 0} ->
        {:ok, output}

      {output, exit} ->
        {:error, output, exit}
    end
  end
end
