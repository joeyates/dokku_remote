defmodule DokkuRemote.Dokku.Command.App do
  alias DokkuRemote.App

  @system_impl Application.compile_env(:dokku_remote, :System, System)

  @callback run(app :: %App{}, command :: String.t()) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(app :: %App{}, command :: String.t(), params :: [String.t()]) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}

  def run(%App{} = app, command, params \\ []) do
    into =
      if app.verbose do
        CollectableStreamer.new(fn line -> IO.write(line) end)
      else
        ""
      end

    args = ["dokku@#{app.dokku_host}", command, app.dokku_app | params]

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
