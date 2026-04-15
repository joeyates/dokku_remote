defmodule DokkuRemote.Dokku.Command.AppTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import Mox

  alias DokkuRemote.Dokku.Command.App, as: AppCommand
  alias DokkuRemote.App

  setup :verify_on_exit!

  describe "new/1" do
    test "creates a struct with given options" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")
      assert app.dokku_app == "my-app"
      assert app.dokku_host == "dokku.example.com"
      assert app.verbose == false
    end

    test "accepts verbose option" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com", verbose: true)
      assert app.verbose == true
    end
  end

  describe "run/3" do
    test "builds the correct SSH program and args" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.System.Mock, :cmd, fn program, args, _opts ->
        assert program == "ssh"
        assert args == ["dokku@dokku.example.com", "apps:exists", "my-app"]
        {"", 0}
      end)

      AppCommand.run(app, "apps:exists")
    end

    test "passes params as additional SSH arguments" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.System.Mock, :cmd, fn _program, args, _opts ->
        assert args == ["dokku@dokku.example.com", "git:from-image", "my-app", "nginx:latest"]
        {"", 0}
      end)

      AppCommand.run(app, "git:from-image", ["nginx:latest"])
    end

    test "returns {:ok, output} on success" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"some output", 0} end)

      assert {:ok, "some output"} = AppCommand.run(app, "apps:list")
    end

    test "returns {:error, output, exit_code} on failure" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"error output", 1} end)

      assert {:error, "error output", 1} = AppCommand.run(app, "apps:list")
    end
  end

  describe "run/3 with verbose: true" do
    test "prints the SSH command before running" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com", verbose: true)

      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"", 0} end)

      output =
        capture_io(fn ->
          AppCommand.run(app, "apps:list")
        end)

      assert output =~ "ssh dokku@dokku.example.com apps:list"
    end
  end
end
