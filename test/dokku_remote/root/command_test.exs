defmodule DokkuRemote.Root.CommandTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import Mox

  alias DokkuRemote.Root.Command

  setup :verify_on_exit!

  describe "run/2" do
    test "builds the correct root SSH program and args" do
      expect(DokkuRemote.System.Mock, :cmd, fn program, args, _opts ->
        assert program == "ssh"
        assert args == ["root@dokku.example.com", "some-command"]
        {"output", 0}
      end)

      Command.run("dokku.example.com", "some-command")
    end

    test "returns {:ok, output} on success" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"ok output", 0} end)

      assert Command.run("dokku.example.com", "some-command") == {:ok, "ok output"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"fail", 2} end)

      assert Command.run("dokku.example.com", "some-command") == {:error, "fail", 2}
    end
  end

  describe "run/3 with verbose: true" do
    test "prints the SSH command before running" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"", 0} end)

      output =
        capture_io(fn ->
          Command.run("dokku.example.com", "some-command", verbose: true)
        end)

      assert output =~ "ssh root@dokku.example.com some-command"
    end
  end
end
