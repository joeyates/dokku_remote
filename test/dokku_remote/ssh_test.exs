defmodule DokkuRemote.SshTest do
  # async: false because some tests modify Application env
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO
  import Mox

  alias DokkuRemote.Ssh

  setup :verify_on_exit!

  defp put_ssh_config(config) do
    previous = Application.get_env(:dokku_remote, DokkuRemote.Ssh)

    Application.put_env(:dokku_remote, DokkuRemote.Ssh, config)

    on_exit(fn ->
      if previous == nil do
        Application.delete_env(:dokku_remote, DokkuRemote.Ssh)
      else
        Application.put_env(:dokku_remote, DokkuRemote.Ssh, previous)
      end
    end)
  end

  describe "run/3" do
    test "runs ssh with user@host and command" do
      expect(DokkuRemote.System.Mock, :cmd, fn program, args, _opts ->
        assert program == "ssh"
        assert args == ["dokku@dokku.example.com", "some-command"]
        {"", 0}
      end)

      Ssh.run("dokku.example.com", "dokku", "some-command")
    end

    test "returns {:ok, output} on success" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"hello", 0} end)

      assert Ssh.run("dokku.example.com", "dokku", "version") == {:ok, "hello"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"error msg", 2} end)

      assert Ssh.run("dokku.example.com", "dokku", "version") == {:error, "error msg", 2}
    end
  end

  describe "run/4 with params" do
    test "appends params after user@host and command" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, args, _opts ->
        assert args == ["dokku@dokku.example.com", "apps:create", "my-app"]
        {"", 0}
      end)

      Ssh.run("dokku.example.com", "dokku", "apps:create", ["my-app"])
    end
  end

  describe "run/5 with verbose: true" do
    test "prints the SSH command before running" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"", 0} end)

      output =
        capture_io(fn ->
          Ssh.run("dokku.example.com", "dokku", "version", [], verbose: true)
        end)

      assert output =~ "ssh dokku@dokku.example.com version"
    end
  end

  describe "config: ssh_args" do
    test "prepends extra SSH args for matching host and user" do
      put_ssh_config(%{"dokku.example.com" => %{"dokku" => ["-i", "/path/to/key"]}})

      expect(DokkuRemote.System.Mock, :cmd, fn _prog, args, _opts ->
        assert args == ["-i", "/path/to/key", "dokku@dokku.example.com", "version"]
        {"", 0}
      end)

      Ssh.run("dokku.example.com", "dokku", "version")
    end

    test "prepends no extra args when host is not in config" do
      put_ssh_config(%{"other.host" => %{"dokku" => ["-i", "/path/to/key"]}})

      expect(DokkuRemote.System.Mock, :cmd, fn _prog, args, _opts ->
        assert args == ["dokku@dokku.example.com", "version"]
        {"", 0}
      end)

      Ssh.run("dokku.example.com", "dokku", "version")
    end

    test "prepends no extra args when user is not in config for the host" do
      put_ssh_config(%{"dokku.example.com" => %{"other-user" => ["-i", "/path/to/key"]}})

      expect(DokkuRemote.System.Mock, :cmd, fn _prog, args, _opts ->
        assert args == ["dokku@dokku.example.com", "version"]
        {"", 0}
      end)

      Ssh.run("dokku.example.com", "dokku", "version")
    end

    test "prepends no extra args when config is empty" do
      put_ssh_config(%{})

      expect(DokkuRemote.System.Mock, :cmd, fn _prog, args, _opts ->
        assert args == ["dokku@dokku.example.com", "version"]
        {"", 0}
      end)

      Ssh.run("dokku.example.com", "dokku", "version")
    end

    test "raises ArgumentError when config is not a map" do
      put_ssh_config(some: :list)

      assert_raise ArgumentError, ~r/Expected DokkuRemote.Ssh configuration to be a map/, fn ->
        Ssh.run("dokku.example.com", "dokku", "version")
      end
    end
  end
end
