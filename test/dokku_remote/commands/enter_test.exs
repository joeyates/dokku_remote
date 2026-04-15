defmodule DokkuRemote.Commands.EnterTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Enter

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "run/1" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "enter", ["my-app"] ->
        {:ok, ""}
      end)

      assert Enter.run(app()) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "enter", ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert Enter.run(app()) == {:error, "App my-app does not exist", 1}
    end
  end
end
