defmodule DokkuRemote.Commands.Logs.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Logs.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "get/2" do
    test "returns log output with no options" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "logs", ["my-app"] ->
        {:ok, "log line 1\nlog line 2\n"}
      end)

      assert App.get(app()) == {:ok, "log line 1\nlog line 2\n"}
    end

    test "passes --num flag when n: option is given" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "logs",
                                                          ["my-app", "--num", "50"] ->
        {:ok, "log line\n"}
      end)

      assert App.get(app(), n: 50) == {:ok, "log line\n"}
    end

    test "passes --tail flag when tail: true is given" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "logs", ["my-app", "--tail"] ->
        {:ok, ""}
      end)

      assert App.get(app(), tail: true) == {:ok, ""}
    end

    test "passes --ps flag when process_type: option is given" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "logs",
                                                          ["my-app", "--ps", "web"] ->
        {:ok, "web log\n"}
      end)

      assert App.get(app(), process_type: "web") == {:ok, "web log\n"}
    end

    test "combines multiple options" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "logs",
                                                          ["my-app", "--num", "10", "--ps", "web"] ->
        {:ok, "web log\n"}
      end)

      assert App.get(app(), n: 10, process_type: "web") == {:ok, "web log\n"}
    end

    test "does not pass --tail flag when tail: false is given" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "logs", ["my-app"] ->
        {:ok, ""}
      end)

      assert App.get(app(), tail: false) == {:ok, ""}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "logs", ["my-app"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.get(app()) == {:error, "App my-app does not exist", 1}
    end
  end
end
