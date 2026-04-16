defmodule DokkuRemote.Commands.PostgresTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Postgres

  setup :verify_on_exit!

  @dokku_host "dokku.example.com"

  @list_output """
  =====> Postgres services
  my-db
  other-db
  """

  describe "list/1" do
    test "returns {:ok, list} of service names on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "postgres:list" ->
        {:ok, @list_output}
      end)

      assert Postgres.list(@dokku_host) == {:ok, ["my-db", "other-db"]}
    end

    test "returns {:ok, empty list} when there are no services" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "postgres:list" ->
        {:ok, "=====> Postgres services\n"}
      end)

      assert Postgres.list(@dokku_host) == {:ok, []}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "postgres:list" ->
        {:error, "connection refused", 1}
      end)

      assert Postgres.list(@dokku_host) == {:error, "connection refused", 1}
    end
  end
end
