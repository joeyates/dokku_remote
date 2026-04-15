defmodule DokkuRemote.Commands.Proxy.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Proxy.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "enabled?/1" do
    test "returns {:ok, true} when proxy is enabled" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "proxy:report" ->
        {:ok, "=====> my-app proxy information\n  Proxy enabled:                 true\n"}
      end)

      assert App.enabled?(app()) == {:ok, true}
    end

    test "returns {:ok, false} when proxy is disabled" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "proxy:report" ->
        {:ok, "=====> my-app proxy information\n  Proxy enabled:                 false\n"}
      end)

      assert App.enabled?(app()) == {:ok, false}
    end

    test "returns {:error, message, -1} on unexpected output" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "proxy:report" ->
        {:ok, "some unexpected output"}
      end)

      assert {:error, "Unexpected output: some unexpected output", -1} = App.enabled?(app())
    end

    test "returns {:error, output, exit_code} on command failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "proxy:report" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.enabled?(app()) == {:error, "App my-app does not exist", 1}
    end
  end

  describe "disable/1" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "proxy:disable" ->
        {:ok, ""}
      end)

      assert App.disable(app()) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "proxy:disable" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.disable(app()) == {:error, "App my-app does not exist", 1}
    end
  end
end
