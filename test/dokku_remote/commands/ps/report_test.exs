defmodule DokkuRemote.Commands.Ps.ReportTest do
  use ExUnit.Case, async: true

  alias DokkuRemote.Commands.Ps.Report
  alias DokkuRemote.Commands.Ps.Report.StatusEntry

  @sample_output """
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

  describe "from_output/1" do
    test "parses the output correctly" do
      {:ok, report} = Report.from_output(@sample_output)

      assert report == %Report{
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
                 %StatusEntry{
                   cid: "1fb72325e15",
                   index: 1,
                   process_name: "web",
                   running: true
                 }
               ],
               stop_timeout_seconds: 30
             }
    end
  end
end
