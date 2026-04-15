defmodule DokkuRemote.CommandTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import Mox

  alias DokkuRemote.Command

  setup :verify_on_exit!

  describe "run/2" do
    test "builds the correct SSH program and args" do
      expect(DokkuRemote.System.Mock, :cmd, fn program, args, _opts ->
        assert program == "ssh"
        assert args == ["dokku@dokku.example.com", "some-command", "--option", "value"]
        {"output", 0}
      end)

      Command.run("dokku.example.com", "some-command", ["--option", "value"])
    end

    test "returns {:ok, output} on success" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"dokku v0.30.0", 0} end)

      assert Command.run("dokku.example.com", "version") == {:ok, "dokku v0.30.0"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"error output", 1} end)

      assert Command.run("dokku.example.com", "version") == {:error, "error output", 1}
    end
  end

  describe "run/3 with verbose: true" do
    test "prints the SSH command before running" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"", 0} end)

      output =
        capture_io(fn ->
          Command.run("dokku.example.com", "version", [], verbose: true)
        end)

      assert output =~ "ssh dokku@dokku.example.com version"
    end
  end
end
