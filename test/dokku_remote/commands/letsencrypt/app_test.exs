defmodule DokkuRemote.Commands.Letsencrypt.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Letsencrypt.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "set/3" do
    test "runs letsencrypt:set and returns :ok" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app,
                                                          "letsencrypt:set",
                                                          ["email", "user@example.com"] ->
        {:ok, ""}
      end)

      assert App.set(app, "email", "user@example.com") == :ok
    end

    test "returns error tuple on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, _cmd, _params ->
        {:error, "connection refused", 1}
      end)

      assert App.set(app, "email", "user@example.com") == {:error, "connection refused", 1}
    end
  end

  describe "unset/2" do
    test "runs letsencrypt:set (unset) and returns :ok" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "letsencrypt:set", ["email"] ->
        {:ok, ""}
      end)

      assert App.unset(app, "email") == :ok
    end

    test "returns error tuple on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, _cmd, _params ->
        {:error, "connection refused", 1}
      end)

      assert App.unset(app, "email") == {:error, "connection refused", 1}
    end
  end

  describe "enable/1" do
    test "runs letsencrypt:enable and returns :ok" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "letsencrypt:enable" ->
        {:ok, ""}
      end)

      assert App.enable(app) == :ok
    end

    test "returns error tuple on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.enable(app) == {:error, "connection refused", 1}
    end
  end
end
