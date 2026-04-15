defmodule DokkuRemote.AppCommand do
  @required_keys [:dokku_app, :dokku_host]
  @enforce_keys @required_keys
  defstruct @required_keys ++ [verbose: false]

  @system_impl Application.compile_env(:dokku_remote, :System, System)

  def new(opts) do
    struct!(__MODULE__, opts)
  end

  @callback run(app :: %__MODULE__{}, command :: String.t(), params :: [String.t()]) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}

  def run(%__MODULE__{} = app, command, params \\ []) do
    into =
      if app.verbose do
        CollectableStreamer.new(fn line -> IO.write(line) end)
      else
        ""
      end

    args = ["dokku@#{app.dokku_host}", command | params]

    if app.verbose do
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
