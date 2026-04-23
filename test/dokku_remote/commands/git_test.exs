defmodule DokkuRemote.Commands.GitTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Git
  alias DokkuRemote.Commands.Git.Report

  setup :verify_on_exit!

  @dokku_host "dokku.example.com"

  @sample_output """
  =====> my-app git information
         Git deploy branch:           main
         Git global deploy branch:    master
         Git keep git dir:            false
         Git rev env var:             GIT_REV
         Git sha:                     abc123def456
         Git source image:
         Git last updated at:         1713225600
  =====> other-app git information
         Git deploy branch:           develop
         Git global deploy branch:    master
         Git keep git dir:            true
         Git rev env var:             GIT_REV
         Git sha:                     deadbeef1234
         Git source image:            nginx:latest
         Git last updated at:         1713312000
  """

  describe "report/1" do
    test "returns {:ok, map} with parsed reports on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "git:report" ->
        {:ok, @sample_output}
      end)

      assert {:ok, reports} = Git.report(@dokku_host)

      assert %Report{
               app_name: "my-app",
               deploy_branch: "main",
               global_deploy_branch: "master",
               keep_git_dir: false,
               rev_env_var: "GIT_REV",
               sha: "abc123def456",
               source_image: "",
               last_updated_at: 1_713_225_600
             } = reports["my-app"]

      assert %Report{
               app_name: "other-app",
               deploy_branch: "develop",
               global_deploy_branch: "master",
               keep_git_dir: true,
               rev_env_var: "GIT_REV",
               sha: "deadbeef1234",
               source_image: "nginx:latest",
               last_updated_at: 1_713_312_000
             } = reports["other-app"]
    end

    test "handles an app with no git deployment (missing optional fields)" do
      output = """
      =====> new-app git information
      Git deploy branch:           main
      Git global deploy branch:    master
      Git keep git dir:            false
      Git rev env var:             GIT_REV
      """

      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "git:report" ->
        {:ok, output}
      end)

      assert {:ok, reports} = Git.report(@dokku_host)

      assert %Report{app_name: "new-app", sha: nil, source_image: nil, last_updated_at: nil} =
               reports["new-app"]
    end

    test "returns {:ok, empty map} when output is empty" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "git:report" ->
        {:ok, ""}
      end)

      assert Git.report(@dokku_host) == {:ok, %{}}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "git:report" ->
        {:error, "connection refused", 1}
      end)

      assert Git.report(@dokku_host) == {:error, "connection refused", 1}
    end
  end
end
