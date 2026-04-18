defmodule DokkuRemote.Commands.Enter.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Enter.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "run/1" do
    test "returns :ok on success" do
      app = app()

      expect(
        DokkuRemote.Dokku.Command.App.Mock,
        :run,
        fn ^app, "enter", ["web", "pwd"] ->
          {:ok, "/app"}
        end
      )

      assert App.run(app, "web", ["pwd"]) == {:ok, "/app"}
    end

    test "returns {:error, output, exit_code} on failure" do
      app = app()

      expect(
        DokkuRemote.Dokku.Command.App.Mock,
        :run,
        fn ^app, "enter", ["web", "pwd"] ->
          {:error, "App my-app does not exist", 1}
        end
      )

      assert App.run(app, "web", ["pwd"]) ==
               {:error, "App my-app does not exist", 1}
    end
  end
end
