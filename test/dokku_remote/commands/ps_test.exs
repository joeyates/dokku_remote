defmodule DokkuRemote.Commands.PsTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Ps
  alias DokkuRemote.Commands.Ps.Scale

  setup :verify_on_exit!

  @dokku_host "dokku.example.com"

  @all_apps_output """
  -----> Scaling for my-app
  proctype: qty
  --------: ---
  web:      1
  -----> Scaling for other-app
  proctype: qty
  --------: ---
  web:      2
  worker:   1
  """

  @single_app_output """
  -----> Scaling for my-app
  proctype: qty
  --------: ---
  web:      1
  """

  describe "scale/1" do
    test "returns {:ok, map} with parsed scales on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "ps:scale", [] ->
        {:ok, @all_apps_output}
      end)

      assert {:ok, scales} = Ps.scale(@dokku_host)

      assert %Scale{
               app_name: "my-app",
               proctypes: %{"web" => 1}
             } = scales["my-app"]

      assert %Scale{
               app_name: "other-app",
               proctypes: %{"web" => 2, "worker" => 1}
             } = scales["other-app"]
    end

    test "returns {:ok, empty map} when output is empty" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "ps:scale", [] ->
        {:ok, ""}
      end)

      assert Ps.scale(@dokku_host) == {:ok, %{}}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "ps:scale", [] ->
        {:error, "connection refused", 1}
      end)

      assert Ps.scale(@dokku_host) == {:error, "connection refused", 1}
    end
  end

  describe "scale/2" do
    test "returns {:ok, Scale} with parsed scale for a specific app on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "ps:scale",
                                                      ["my-app"] ->
        {:ok, @single_app_output}
      end)

      assert {:ok, scale} = Ps.scale(@dokku_host, "my-app")

      assert %Scale{
               app_name: "my-app",
               proctypes: %{"web" => 1}
             } = scale
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com",
                                                      "ps:scale",
                                                      ["my-app"] ->
        {:error, "not found", 1}
      end)

      assert Ps.scale(@dokku_host, "my-app") == {:error, "not found", 1}
    end
  end
end
