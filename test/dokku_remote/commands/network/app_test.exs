defmodule DokkuRemote.Commands.Network.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Network.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "get/2" do
    test "returns {:ok, trimmed_value} on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "network:report",
                                                          [
                                                            "my-app",
                                                            "--network-attach-post-create"
                                                          ] ->
        {:ok, "mynet\n"}
      end)

      assert App.get(app(), "attach-post-create") == {:ok, "mynet"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "network:report",
                                                          [
                                                            "my-app",
                                                            "--network-attach-post-create"
                                                          ] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.get(app(), "attach-post-create") ==
               {:error, "App my-app does not exist", 1}
    end
  end

  describe "report/1" do
    test "returns {:ok, output} on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "network:report", ["my-app"] ->
        {:ok, "=====> my-app network information\n  Network attach post create:  \n"}
      end)

      assert App.report(app()) ==
               {:ok, "=====> my-app network information\n  Network attach post create:  \n"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "network:report", ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.report(app()) == {:error, "App my-app does not exist", 1}
    end
  end

  describe "set/3" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "network:set",
                                                          [
                                                            "my-app",
                                                            "attach-post-create",
                                                            "mynet"
                                                          ] ->
        {:ok, ""}
      end)

      assert App.set(app(), "attach-post-create", "mynet") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "network:set",
                                                          [
                                                            "my-app",
                                                            "attach-post-create",
                                                            "mynet"
                                                          ] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.set(app(), "attach-post-create", "mynet") ==
               {:error, "App my-app does not exist", 1}
    end
  end
end
