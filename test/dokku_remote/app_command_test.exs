defmodule DokkuRemote.AppCommandTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import Mox

  alias DokkuRemote.AppCommand

  setup :verify_on_exit!

  describe "new/1" do
    test "creates a struct with given options" do
      app = AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")
      assert app.dokku_app == "my-app"
      assert app.dokku_host == "dokku.example.com"
      assert app.verbose == false
    end

    test "accepts verbose option" do
      app = AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com", verbose: true)
      assert app.verbose == true
    end
  end

  describe "run/2" do
    test "builds the correct SSH command" do
      app = AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.System.Mock, :shell, fn cmd, _opts ->
        assert cmd == "ssh dokku@dokku.example.com apps:list 2>&1"
        {"", 0}
      end)

      AppCommand.run(app, "apps:list")
    end

    test "returns {:ok, output} on success" do
      app = AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.System.Mock, :shell, fn _cmd, _opts -> {"some output", 0} end)

      assert {:ok, "some output"} = AppCommand.run(app, "apps:list")
    end

    test "returns {:error, output, exit_code} on failure" do
      app = AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.System.Mock, :shell, fn _cmd, _opts -> {"error output", 1} end)

      assert {:error, "error output", 1} = AppCommand.run(app, "apps:list")
    end
  end

  describe "run/2 with verbose: true" do
    test "prints the command before running" do
      app = AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com", verbose: true)

      expect(DokkuRemote.System.Mock, :shell, fn _cmd, _opts -> {"", 0} end)

      output =
        capture_io(fn ->
          AppCommand.run(app, "apps:list")
        end)

      assert output =~ "ssh dokku@dokku.example.com apps:list 2>&1"
    end
  end
end
