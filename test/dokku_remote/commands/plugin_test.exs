defmodule DokkuRemote.Commands.PluginTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Plugin
  alias DokkuRemote.Commands.Plugin.Entry

  setup :verify_on_exit!

  @dokku_host "dokku.example.com"

  @sample_output """
    00_dokku-standard    0.37.2 enabled    dokku core standard plugin
    20_events            0.37.2 enabled    dokku core events logging plugin
    apps                 0.37.2 enabled    dokku core apps plugin
    http-auth            0.10.0 disabled   HTTP authentication for apps
  """

  describe "list/1" do
    test "returns {:ok, list} with parsed entries on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "plugin:list" ->
        {:ok, @sample_output}
      end)

      assert {:ok, entries} = Plugin.list(@dokku_host)

      assert [
               %Entry{
                 name: "00_dokku-standard",
                 version: "0.37.2",
                 enabled: true,
                 description: "dokku core standard plugin"
               },
               %Entry{
                 name: "20_events",
                 version: "0.37.2",
                 enabled: true,
                 description: "dokku core events logging plugin"
               },
               %Entry{
                 name: "apps",
                 version: "0.37.2",
                 enabled: true,
                 description: "dokku core apps plugin"
               },
               %Entry{
                 name: "http-auth",
                 version: "0.10.0",
                 enabled: false,
                 description: "HTTP authentication for apps"
               }
             ] = entries
    end

    test "returns {:ok, empty list} when output is empty" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "plugin:list" ->
        {:ok, ""}
      end)

      assert Plugin.list(@dokku_host) == {:ok, []}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "plugin:list" ->
        {:error, "connection refused", 1}
      end)

      assert Plugin.list(@dokku_host) == {:error, "connection refused", 1}
    end
  end
end
