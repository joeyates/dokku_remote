defmodule DokkuRemote.Commands.Git.ReportTest do
  use ExUnit.Case, async: true

  alias DokkuRemote.Commands.Git.Report

  @report_output """
  =====> my-app git information
         Git deploy branch:           main
         Git global deploy branch:    master
         Git keep git dir:            false
         Git rev env var:             GIT_REV
         Git sha:                     abc123def456
         Git source image:
         Git last updated at:         1713225600
  """

  @report_output_without_last_updated_at """
  =====> my-app git information
         Git deploy branch:           main
         Git global deploy branch:    master
         Git keep git dir:            false
         Git rev env var:             GIT_REV
         Git sha:                     abc123def456
         Git source image:
         Git last updated at:
  """

  test "from_output/1 parses report output into struct" do
    {:ok, report} = Report.from_output(@report_output)

    assert report ==
             %Report{
               app_name: "my-app",
               deploy_branch: "main",
               global_deploy_branch: "master",
               keep_git_dir: false,
               rev_env_var: "GIT_REV",
               sha: "abc123def456",
               source_image: nil,
               last_updated_at: 1_713_225_600
             }
  end

  test "from_output/1 handles missing optional fields" do
    {:ok, report} = Report.from_output(@report_output_without_last_updated_at)

    assert report ==
             %Report{
               app_name: "my-app",
               deploy_branch: "main",
               global_deploy_branch: "master",
               keep_git_dir: false,
               rev_env_var: "GIT_REV",
               sha: "abc123def456",
               source_image: nil,
               last_updated_at: nil
             }
  end
end
