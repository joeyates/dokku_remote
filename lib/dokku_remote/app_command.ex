defmodule DokkuRemote.AppCommand do
  @required_keys [:dokku_app, :dokku_host]
  @enforce_keys @required_keys
  defstruct @required_keys ++ [verbose: false]

  def new(opts) do
    struct!(__MODULE__, opts)
  end

  def run(%__MODULE__{} = app, command) do
    into =
      if app.verbose do
        CollectableStreamer.new(fn line -> IO.write(line) end)
      else
        ""
      end

    full_command = "ssh dokku@#{app.dokku_host} #{command} 2>&1"

    if app.verbose do
      IO.puts("Running command: #{full_command}")
    end

    case System.shell(full_command, into: into) do
      {output, 0} ->
        {:ok, output}

      {output, exit} ->
        {:error, output, exit}
    end
  end
end
