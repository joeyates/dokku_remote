defmodule DokkuRemote.Commands.Ports.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Ports.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "get_prococol_mapping/2" do
    test "returns {:ok, host_port, container_port} on success" do
      output =
        "=====> Port mappings for my-app\n-----> scheme  host_port  container_port\n       http   80   3000\n"

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ports:list" ->
        {:ok, output}
      end)

      assert App.get_prococol_mapping(app(), "http") == {:ok, 80, 3000}
    end

    test "returns {:error, :not_set} when no mapping exists for the protocol" do
      output = "=====> Port mappings for my-app\n"

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ports:list" ->
        {:ok, output}
      end)

      assert App.get_prococol_mapping(app(), "http") == {:error, :not_set}
    end

    test "returns {:error, output, exit_code} on command failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ports:list" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.get_prococol_mapping(app(), "http") == {:error, "App my-app does not exist", 1}
    end
  end

  describe "set_protocol_mapping/3" do
    test "runs ports:set for http:80 and returns :ok" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, "ports:set", ["http:80:3000"] ->
        {:ok, ""}
      end)

      assert App.set_protocol_mapping(app(), "http", 3000) == :ok
    end

    test "returns error tuple on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app, _cmd, _params ->
        {:error, "connection refused", 1}
      end)

      assert App.set_protocol_mapping(app(), "http", 3000) == {:error, "connection refused", 1}
    end
  end
end
