defmodule DokkuRemote.Commands.Proxy.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.AppCommand
  alias DokkuRemote.Commands.Proxy.App

  setup :verify_on_exit!

  defp app(), do: AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "disable/1" do
    test "returns :ok on success" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "proxy:disable my-app" ->
        {:ok, ""}
      end)

      assert App.disable(app()) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "proxy:disable my-app" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.disable(app()) == {:error, "App my-app does not exist", 1}
    end
  end
end
