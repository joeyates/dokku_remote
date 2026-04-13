defmodule DokkuRemote.Commands.DockerOptions.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.AppCommand
  alias DokkuRemote.Commands.DockerOptions.App

  setup :verify_on_exit!

  defp app(), do: AppCommand.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "add/3" do
    test "returns :ok on success" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "docker-options:add my-app deploy --restart=always" ->
        {:ok, ""}
      end)

      assert App.add(app(), "deploy", "--restart=always") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.AppCommand.Mock, :run, fn _app,
                                                   "docker-options:add my-app run --cap-add=NET_ADMIN" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.add(app(), "run", "--cap-add=NET_ADMIN") == {:error, "App my-app does not exist", 1}
    end
  end
end
