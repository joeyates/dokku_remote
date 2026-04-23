defmodule DokkuRemote.Commands.Ps.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Ps.App
  alias DokkuRemote.Commands.Ps.Scale

  @scale_single_app_output """
  -----> Scaling for my-app
  proctype: qty
  --------: ---
  web:      1
  """

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "rebuild/1" do
    test "returns :ok on success" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:rebuild" ->
        {:ok, ""}
      end)

      assert App.rebuild(app) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:rebuild" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.rebuild(app) == {:error, "App my-app does not exist", 1}
    end
  end

  @report_app_output """
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
  """

  describe "report/1" do
    test "returns {:ok, output} on success" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:report" ->
        {:ok, @report_app_output}
      end)

      assert App.report(app) ==
               {
                 :ok,
                 %DokkuRemote.Commands.Ps.Report{
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
                   status_entries: [
                     %DokkuRemote.Commands.Ps.Report.StatusEntry{
                       cid: "1fb72325e15",
                       index: 1,
                       process_name: "web",
                       running: true
                     }
                   ],
                   stop_timeout_seconds: 30
                 }
               }
    end

    test "returns {:error, output, exit_code} on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:report" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.report(app) == {:error, "App my-app does not exist", 1}
    end
  end

  describe "restart/1" do
    test "returns :ok on success" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:restart" ->
        {:ok, ""}
      end)

      assert App.restart(app) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:restart" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.restart(app) == {:error, "App my-app does not exist", 1}
    end
  end

  describe "scale/2" do
    test "returns {:ok, Scale} with parsed scale for a specific app on success" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:scale" ->
        {:ok, @scale_single_app_output}
      end)

      assert {:ok, scale} = App.scale(app)

      assert %Scale{
               app_name: "my-app",
               proctypes: %{"web" => 1}
             } = scale
    end

    test "returns {:error, output, exit_code} on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:scale" ->
        {:error, "not found", 1}
      end)

      assert App.scale(app) == {:error, "not found", 1}
    end
  end

  describe "stop/1" do
    test "returns :ok on success" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:stop" ->
        {:ok, ""}
      end)

      assert App.stop(app) == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      app = app()

      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn ^app, "ps:stop" ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.stop(app) == {:error, "App my-app does not exist", 1}
    end
  end
end
