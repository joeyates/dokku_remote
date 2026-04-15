defmodule DokkuRemote.RootCommandTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import Mox

  alias DokkuRemote.RootCommand

  setup :verify_on_exit!

  describe "run/2" do
    test "builds the correct root SSH command" do
      expect(DokkuRemote.System.Mock, :shell, fn cmd, _opts ->
        assert cmd == "ssh root@dokku.example.com some-command 2>&1"
        {"output", 0}
      end)

      RootCommand.run("dokku.example.com", "some-command")
    end

    test "returns {:ok, output} on success" do
      expect(DokkuRemote.System.Mock, :shell, fn _cmd, _opts -> {"ok output", 0} end)

      assert RootCommand.run("dokku.example.com", "some-command") == {:ok, "ok output"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.System.Mock, :shell, fn _cmd, _opts -> {"fail", 2} end)

      assert RootCommand.run("dokku.example.com", "some-command") == {:error, "fail", 2}
    end
  end

  describe "run/3 with verbose: true" do
    test "prints the command before running" do
      expect(DokkuRemote.System.Mock, :shell, fn _cmd, _opts -> {"", 0} end)

      output =
        capture_io(fn ->
          RootCommand.run("dokku.example.com", "some-command", verbose: true)
        end)

      assert output =~ "ssh root@dokku.example.com some-command 2>&1"
    end
  end
end
