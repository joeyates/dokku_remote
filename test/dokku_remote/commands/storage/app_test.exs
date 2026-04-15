defmodule DokkuRemote.Commands.Storage.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Storage.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "mount_exists?/3" do
    test "returns {:ok, true} when the mount is present" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "storage:report",
                                                          ["my-app", "--storage-run-mounts"] ->
        {:ok, "/var/data:/app/data\n"}
      end)

      assert App.mount_exists?(app(), "/var/data", "/app/data") == {:ok, true}
    end

    test "returns {:ok, false} when the mount is absent" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "storage:report",
                                                          ["my-app", "--storage-run-mounts"] ->
        {:ok, "/other/path:/other/container\n"}
      end)

      assert App.mount_exists?(app(), "/var/data", "/app/data") == {:ok, false}
    end

    test "returns {:error, output, exit_code} on command failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "storage:report",
                                                          ["my-app", "--storage-run-mounts"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.mount_exists?(app(), "/var/data", "/app/data") ==
               {:error, "App my-app does not exist", 1}
    end
  end

  describe "ensure_directory/2" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "storage:ensure-directory",
                                                          ["my-app", "/var/data"] ->
        {:ok, ""}
      end)

      assert App.ensure_directory(app(), "/var/data") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "storage:ensure-directory",
                                                          ["my-app", "/var/data"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.ensure_directory(app(), "/var/data") == {:error, "App my-app does not exist", 1}
    end
  end

  describe "mount/3" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "storage:mount",
                                                          ["my-app", "/var/data:/app/data"] ->
        {:ok, ""}
      end)

      assert App.mount(app(), "/var/data", "/app/data") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "storage:mount",
                                                          ["my-app", "/var/data:/app/data"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.mount(app(), "/var/data", "/app/data") ==
               {:error, "App my-app does not exist", 1}
    end
  end
end
