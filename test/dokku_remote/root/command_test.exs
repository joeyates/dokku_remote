defmodule DokkuRemote.Root.CommandTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Root.Command

  setup :verify_on_exit!

  describe "run/2" do
    test "delegates to Ssh.Mock with user root and one command" do
      expect(DokkuRemote.Ssh.Mock, :run, fn host, user, command, params, _opts ->
        assert host == "dokku.example.com"
        assert user == "root"
        assert command == "some-command"
        assert params == []
        {:ok, "output"}
      end)

      Command.run("dokku.example.com", "some-command")
    end

    test "delegates to Ssh.Mock with user root and multiple params" do
      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, params, _opts ->
        assert params == ["param1", "param2"]
        {:ok, "output"}
      end)

      Command.run("dokku.example.com", "some-command", ["param1", "param2"])
    end

    test "returns {:ok, output} on success" do
      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, _opts ->
        {:ok, "ok output"}
      end)

      assert Command.run("dokku.example.com", "some-command") == {:ok, "ok output"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, _opts ->
        {:error, "fail", 2}
      end)

      assert Command.run("dokku.example.com", "some-command") == {:error, "fail", 2}
    end
  end

  describe "run/3 with verbose: true" do
    test "passes verbose: true to Ssh.Mock" do
      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, opts ->
        assert Keyword.get(opts, :verbose) == true
        {:ok, ""}
      end)

      Command.run("dokku.example.com", "some-command", [], verbose: true)
    end
  end
end
