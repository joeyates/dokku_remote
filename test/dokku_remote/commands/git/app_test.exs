defmodule DokkuRemote.Commands.Git.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.AppCommand
  alias DokkuRemote.Commands.Git.App

  setup :verify_on_exit!

  defp app(), do: AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "from_image/2" do
    test "returns :ok on success" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "git:from-image",
                                                   ["my-app", "nginx:latest"] ->
        {:ok, ""}
      end)

      assert App.from_image(app(), "nginx:latest") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "git:from-image",
                                                   ["my-app", "nginx:latest"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.from_image(app(), "nginx:latest") == {:error, "App my-app does not exist", 1}
    end
  end
end
