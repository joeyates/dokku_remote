defmodule DokkuRemote.Commands.Apps.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Apps.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "exists?/1" do
    test "returns true when the app exists" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "apps:exists" ->
        {:ok, ""}
      end)

      assert App.exists?(app) == true
    end

    test "returns false when the app does not exist (exit 20)" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "apps:exists" ->
        {:error, "App my-app does not exist", 20}
      end)

      assert App.exists?(app) == false
    end

    test "raises on unexpected error" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "apps:exists" ->
        {:error, "connection refused", 1}
      end)

      assert_raise RuntimeError, ~r/exit code 1/, fn -> App.exists?(app) end
    end
  end

  describe "running?/1" do
    test "returns true when the app is running" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:report" ->
        {:ok, "=====> my-app ps information\n  Running:           true\n"}
      end)

      assert App.running?(app) == true
    end

    test "returns false when the app is not running" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:report" ->
        {:ok, "=====> my-app ps information\n  Running:           false\n"}
      end)

      assert App.running?(app) == false
    end

    test "raises on error" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:report" ->
        {:error, "connection refused", 1}
      end)

      assert_raise RuntimeError, ~r/exit code 1/, fn -> App.running?(app) end
    end
  end

  describe "create/1" do
    test "returns :ok on success" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "apps:create" ->
        {:ok, ""}
      end)

      assert App.create(app) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "apps:create" ->
        {:error, "app already exists", 1}
      end)

      assert App.create(app) == {:error, "app already exists", 1}
    end
  end
end
