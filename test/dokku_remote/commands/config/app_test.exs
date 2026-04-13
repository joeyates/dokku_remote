defmodule DokkuRemote.Commands.Config.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.AppCommand
  alias DokkuRemote.Commands.Config.App

  setup :verify_on_exit!

  defp app(), do: AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "set/4" do
    test "runs config:set with --no-restart by default" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "config:set --no-restart  my-app FOO=bar" ->
        {:ok, ""}
      end)

      assert App.set(app(), "FOO", "bar") == :ok
    end

    test "runs config:set without --no-restart when restart: true" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "config:set  my-app FOO=bar" ->
        {:ok, ""}
      end)

      assert App.set(app(), "FOO", "bar", restart: true) == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.set(app(), "FOO", "bar") == {:error, "connection refused", 1}
    end
  end

  describe "unset/3" do
    test "runs config:unset with --no-restart by default" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "config:unset --no-restart  my-app FOO" ->
        {:ok, ""}
      end)

      assert App.unset(app(), "FOO") == :ok
    end

    test "runs config:unset without --no-restart when restart: true" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "config:unset  my-app FOO" ->
        {:ok, ""}
      end)

      assert App.unset(app(), "FOO", restart: true) == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.unset(app(), "FOO") == {:error, "connection refused", 1}
    end
  end
end
