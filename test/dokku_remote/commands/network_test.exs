defmodule DokkuRemote.Commands.NetworkTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Network

  setup :verify_on_exit!

  describe "create/2" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "network:create mynet" ->
        {:ok, ""}
      end)

      assert Network.create("dokku.example.com", "mynet") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "network:create mynet" ->
        {:error, "network already exists", 1}
      end)

      assert Network.create("dokku.example.com", "mynet") == {:error, "network already exists", 1}
    end
  end

  describe "exists?/2" do
    test "returns {:ok, true} when the network exists" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "network:exists mynet" ->
        {:ok, "mynet exists"}
      end)

      assert Network.exists?("dokku.example.com", "mynet") == {:ok, true}
    end

    test "returns {:ok, false} when the network does not exist" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "network:exists mynet" ->
        {:ok, "mynet does not exist"}
      end)

      assert Network.exists?("dokku.example.com", "mynet") == {:ok, false}
    end

    test "returns {:error, output, exit_code} on command failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "network:exists mynet" ->
        {:error, "connection refused", 1}
      end)

      assert Network.exists?("dokku.example.com", "mynet") == {:error, "connection refused", 1}
    end

    test "returns {:error, message, -1} on unexpected output" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "network:exists mynet" ->
        {:ok, "some unexpected output"}
      end)

      assert {:error, "Unexpected output: some unexpected output", -1} =
               Network.exists?("dokku.example.com", "mynet")
    end
  end
end
