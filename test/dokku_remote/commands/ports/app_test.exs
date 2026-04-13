defmodule DokkuRemote.Commands.Ports.AppTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias DokkuRemote.AppCommand
  alias DokkuRemote.Commands.Ports.App

  defp app, do: AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "set_80/2" do
    test "runs ports:set for http:80 and returns :ok" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, "ports:set my-app http:80:3000" ->
        {:ok, ""}
      end)

      assert App.set_80(app(), 3000) == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app, _cmd ->
        {:error, "connection refused", 1}
      end)

      assert App.set_80(app(), 3000) == {:error, "connection refused", 1}
    end
  end
end
