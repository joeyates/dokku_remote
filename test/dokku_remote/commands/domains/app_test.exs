defmodule DokkuRemote.Commands.Domains.AppTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias DokkuRemote.AppCommand
  alias DokkuRemote.Commands.Domains.App

  defp app, do: AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "get/1" do
    test "returns the domain when domains are enabled and a vhost is set" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "domains:report my-app" ->
        {:ok,
         "=====> my-app Domain Information\n  Domains app enabled: true\n  Domains app vhosts: my-app.example.com\n"}
      end)

      assert App.get(app()) == {:ok, "my-app.example.com"}
    end

    test "returns {:ok, nil} when domains are disabled" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "domains:report my-app" ->
        {:ok,
         "=====> my-app Domain Information\n  Domains app enabled: false\n  Domains app vhosts: my-app.example.com\n"}
      end)

      assert App.get(app()) == {:ok, nil}
    end

    test "returns {:ok, nil} when no vhost line matches" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "domains:report my-app" ->
        {:ok, "=====> my-app Domain Information\n  Domains app enabled: true\n"}
      end)

      assert App.get(app()) == {:ok, nil}
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "domains:report my-app" ->
        {:error, "connection refused", 1}
      end)

      assert App.get(app()) == {:error, "connection refused", 1}
    end
  end

  describe "set/2" do
    test "runs domains:set and returns :ok" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "domains:set my-app my-app.example.com" ->
        {:ok, ""}
      end)

      assert App.set(app(), "my-app.example.com") == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.set(app(), "my-app.example.com") == {:error, "connection refused", 1}
    end
  end
end
