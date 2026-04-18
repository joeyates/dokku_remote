defmodule DokkuRemote.Commands.PsTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Ps
  alias DokkuRemote.Commands.Ps.Scale

  setup :verify_on_exit!

  @dokku_host "dokku.example.com"

  @report_all_apps_output """
  =====> my-app ps information
         Computed stop timeout seconds: 30
         Deployed:                      true
         Global stop timeout seconds:   30
         Processes:                     1
         Ps can scale:                  true
         Ps computed procfile path:     Procfile
         Ps global procfile path:       Procfile
         Ps procfile path:              
         Ps restart policy:             on-failure:10
         Restore:                       true
         Running:                       true
         Status web 1:                  running (CID: 1fb72325e15)
         Stop timeout seconds:          30
  =====> other-app ps information
         Computed stop timeout seconds: 40
         Deployed:                      true
         Global stop timeout seconds:   50
         Processes:                     2
         Ps can scale:                  false
         Ps computed procfile path:     Procfile
         Ps global procfile path:       Procfile
         Ps procfile path:              
         Ps restart policy:             on-failure:10
         Restore:                       true
         Running:                       true
         Status web 1:                  running (CID: 1fb72325e15)
         Stop timeout seconds:          70
  """

  describe "report/1" do
    test "returns {:ok, list of Report structs} on success" do
      expect(
        DokkuRemote.Dokku.Command.Mock,
        :run,
        fn "dokku.example.com", "ps:report" ->
          {:ok, @report_all_apps_output}
        end
      )

      assert {:ok, reports} = Ps.report(@dokku_host)

      assert reports |> Map.keys() |> length() == 2

      first_report = reports["my-app"]

      assert first_report == %Ps.Report{
               app_name: "my-app",
               computed_stop_timeout_seconds: 30,
               deployed: true,
               global_stop_timeout_seconds: 30,
               processes: 1,
               ps_can_scale: true,
               ps_computed_procfile_path: "Procfile",
               ps_global_procfile_path: "Procfile",
               ps_procfile_path: nil,
               ps_restart_policy: "on-failure:10",
               restore: true,
               running: true,
               stop_timeout_seconds: 30
             }

      second_report = reports["other-app"]

      assert second_report == %Ps.Report{
               app_name: "other-app",
               computed_stop_timeout_seconds: 40,
               deployed: true,
               global_stop_timeout_seconds: 50,
               processes: 2,
               ps_can_scale: false,
               ps_computed_procfile_path: "Procfile",
               ps_global_procfile_path: "Procfile",
               ps_procfile_path: nil,
               ps_restart_policy: "on-failure:10",
               restore: true,
               running: true,
               stop_timeout_seconds: 70
             }
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(
        DokkuRemote.Dokku.Command.Mock,
        :run,
        fn "dokku.example.com", "ps:report" ->
          {:error, "connection refused", 1}
        end
      )

      assert Ps.report(@dokku_host) == {:error, "connection refused", 1}
    end
  end

  @scale_all_apps_output """
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

  describe "scale/1" do
    test "returns {:ok, map} with parsed scales on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "ps:scale", [] ->
        {:ok, @scale_all_apps_output}
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
end
