defmodule DokkuRemote.Commands.RedisTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Redis

  setup :verify_on_exit!

  @dokku_host "dokku.example.com"

  @list_output """
  =====> Redis services
  my-cache
  other-cache
  """

  describe "list/1" do
    test "returns {:ok, list} of service names on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "redis:list" ->
        {:ok, @list_output}
      end)

      assert Redis.list(@dokku_host) == {:ok, ["my-cache", "other-cache"]}
    end

    test "returns {:ok, empty list} when there are no services" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "redis:list" ->
        {:ok, "=====> Redis services\n"}
      end)

      assert Redis.list(@dokku_host) == {:ok, []}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "redis:list" ->
        {:error, "connection refused", 1}
      end)

      assert Redis.list(@dokku_host) == {:error, "connection refused", 1}
    end
  end

  describe "links/2" do
    test "returns {:ok, list} of linked app names on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "redis:links",
                                                      ["my-cache"] ->
        {:ok, "my-app\n"}
      end)

      assert Redis.links(@dokku_host, "my-cache") == {:ok, ["my-app"]}
    end

    test "returns {:ok, empty list} when no apps are linked" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "redis:links",
                                                      ["my-cache"] ->
        {:ok, ""}
      end)

      assert Redis.links(@dokku_host, "my-cache") == {:ok, []}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "redis:links",
                                                      ["my-cache"] ->
        {:error, "not found", 1}
      end)

      assert Redis.links(@dokku_host, "my-cache") == {:error, "not found", 1}
    end
  end
end
