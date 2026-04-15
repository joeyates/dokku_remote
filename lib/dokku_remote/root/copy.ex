defmodule DokkuRemote.Root.Copy do
  @system_impl Application.compile_env(:dokku_remote, :System, System)

  def to_host(dokku_host, local_path, remote_path) do
    args = [local_path, "root@#{dokku_host}:#{remote_path}"]

    case @system_impl.cmd("scp", args, stderr_to_stdout: true) do
      {_output, 0} ->
        :ok

      {output, exit} ->
        {:error, output, exit}
    end
  end
end
