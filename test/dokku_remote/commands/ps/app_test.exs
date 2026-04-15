defmodule DokkuRemote.Commands.Ps.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Ps.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "rebuild/1" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:rebuild", ["my-app"] ->
        {:ok, ""}
      end)

      assert App.rebuild(app()) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:rebuild", ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.rebuild(app()) == {:error, "App my-app does not exist", 1}
    end
  end

  describe "report/1" do
    test "returns {:ok, output} on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:report", ["my-app"] ->
        {:ok, "=====> my-app ps information\n  Running:           true\n"}
      end)

      assert App.report(app()) ==
               {:ok, "=====> my-app ps information\n  Running:           true\n"}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:report", ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.report(app()) == {:error, "App my-app does not exist", 1}
    end
  end

  describe "restart/1" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:restart", ["my-app"] ->
        {:ok, ""}
      end)

      assert App.restart(app()) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:restart", ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.restart(app()) == {:error, "App my-app does not exist", 1}
    end
  end

  describe "stop/1" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:stop", ["my-app"] ->
        {:ok, ""}
      end)

      assert App.stop(app()) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ps:stop", ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.stop(app()) == {:error, "App my-app does not exist", 1}
    end
  end
end
