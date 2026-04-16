defmodule DokkuRemote.Dokku.CommandTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Dokku.Command

  setup :verify_on_exit!

  describe "run/2" do
    test "delegates to Ssh.Mock with correct host, user, command and params" do
      expect(DokkuRemote.Ssh.Mock, :run, fn host, user, command, params, _opts ->
        assert host == "dokku.example.com"
        assert user == "dokku"
        assert command == "some-command"
        assert params == ["--option", "value"]
        {:ok, "output"}
      end)

      Command.run("dokku.example.com", "some-command", ["--option", "value"])
    end

    test "returns {:ok, output} on success" do
      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, _opts ->
        {:ok, "dokku v0.30.0"}
      end)

      assert Command.run("dokku.example.com", "version") == {:ok, "dokku v0.30.0"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, _opts ->
        {:error, "error output", 1}
      end)

      assert Command.run("dokku.example.com", "version") == {:error, "error output", 1}
    end
  end

  describe "run/3 with verbose: true" do
    test "passes verbose: true to Ssh.Mock" do
      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, opts ->
        assert Keyword.get(opts, :verbose) == true
        {:ok, ""}
      end)

      Command.run("dokku.example.com", "version", [], verbose: true)
    end
  end
end
