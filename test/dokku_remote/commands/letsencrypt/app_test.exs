defmodule DokkuRemote.Commands.Letsencrypt.AppTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias DokkuRemote.AppCommand
  alias DokkuRemote.Commands.Letsencrypt.App

  defp app, do: AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "set/3" do
    test "runs letsencrypt:set and returns :ok" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "letsencrypt:set my-app email user@example.com" ->
        {:ok, ""}
      end)

      assert App.set(app(), "email", "user@example.com") == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.set(app(), "email", "user@example.com") == {:error, "connection refused", 1}
    end
  end

  describe "unset/2" do
    test "runs letsencrypt:set (unset) and returns :ok" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "letsencrypt:set my-app email" ->
        {:ok, ""}
      end)

      assert App.unset(app(), "email") == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.unset(app(), "email") == {:error, "connection refused", 1}
    end
  end

  describe "enable/1" do
    test "runs letsencrypt:enable and returns :ok" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "letsencrypt:enable my-app" ->
        {:ok, ""}
      end)

      assert App.enable(app()) == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.enable(app()) == {:error, "connection refused", 1}
    end
  end
end
