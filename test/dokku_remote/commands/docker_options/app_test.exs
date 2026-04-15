defmodule DokkuRemote.Commands.DockerOptions.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.DockerOptions.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "exists?/3" do
    test "returns {:ok, true} when the option is present for the given phase" do
      output = """
      =====> my-app docker options
          Docker options deploy:  --restart=always
          Docker options run:
          Docker options build:
      """

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "docker-options:report",
                                                          ["my-app"] ->
        {:ok, output}
      end)

      assert App.exists?(app(), "deploy", "--restart=always") == {:ok, true}
    end

    test "returns {:ok, false} when the option is absent for the given phase" do
      output = """
      =====> my-app docker options
          Docker options deploy:  --restart=always
          Docker options run:
          Docker options build:
      """

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "docker-options:report",
                                                          ["my-app"] ->
        {:ok, output}
      end)

      assert App.exists?(app(), "run", "--cap-add=NET_ADMIN") == {:ok, false}
    end

    test "returns {:error, output, exit_code} on command failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "docker-options:report",
                                                          ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.exists?(app(), "deploy", "--restart=always") ==
               {:error, "App my-app does not exist", 1}
    end
  end

  describe "add/3" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "docker-options:add",
                                                          ["my-app", "deploy", "--restart=always"] ->
        {:ok, ""}
      end)

      assert App.add(app(), "deploy", "--restart=always") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "docker-options:add",
                                                          ["my-app", "run", "--cap-add=NET_ADMIN"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.add(app(), "run", "--cap-add=NET_ADMIN") ==
               {:error, "App my-app does not exist", 1}
    end
  end
end
