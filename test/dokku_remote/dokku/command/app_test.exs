defmodule DokkuRemote.Dokku.Command.AppTest do
  use ExUnit.Case, async: true

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

  describe "run/2" do
    test "delegates to Ssh.Mock with correct host, user, command and app as first param" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.Ssh.Mock, :run, fn host, user, command, params, _opts ->
        assert host == "dokku.example.com"
        assert user == "dokku"
        assert command == "apps:exists"
        assert params == ["my-app"]
        {:ok, ""}
      end)

      AppCommand.run(app, "apps:exists")
    end

    test "passes params as additional SSH arguments after the app name" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, params, _opts ->
        assert params == ["my-app", "nginx:latest"]
        {:ok, ""}
      end)

      AppCommand.run(app, "git:from-image", ["nginx:latest"])
    end

    test "returns {:ok, output} on success" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, _opts ->
        {:ok, "some output"}
      end)

      assert {:ok, "some output"} = AppCommand.run(app, "apps:list")
    end

    test "returns {:error, output, exit_code} on failure" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, _opts ->
        {:error, "error output", 1}
      end)

      assert {:error, "error output", 1} = AppCommand.run(app, "apps:list")
    end

    test "fails unless an App struct is passed" do
      assert_raise FunctionClauseError, fn ->
        AppCommand.run(%{dokku_app: "my-app", dokku_host: "dokku.example.com"}, "apps:list")
      end
    end
  end

  describe "run/3 with verbose: true" do
    test "passes verbose: true to Ssh.Mock" do
      app = App.new(dokku_app: "my-app", dokku_host: "dokku.example.com", verbose: true)

      expect(DokkuRemote.Ssh.Mock, :run, fn _host, _user, _command, _params, opts ->
        assert Keyword.get(opts, :verbose) == true
        {:ok, ""}
      end)

      AppCommand.run(app, "apps:list")
    end
  end
end
