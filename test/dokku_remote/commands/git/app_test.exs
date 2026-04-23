defmodule DokkuRemote.Commands.Git.AppTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Git.App

  setup :verify_on_exit!

  defp app(), do: DokkuRemote.App.new(dokku_app: "my-app", dokku_host: "dokku.example.com")

  describe "from_image/2" do
    test "returns :ok on success" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "git:from-image",
                                                          ["nginx:latest"] ->
        {:ok, ""}
      end)

      assert App.from_image(app(), "nginx:latest") == :ok
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.App.Mock, :run, fn _app,
                                                          "git:from-image",
                                                          ["nginx:latest"] ->
        {:error, "App my-app does not exist", 1}
      end)

      assert App.from_image(app(), "nginx:latest") == {:error, "App my-app does not exist", 1}
    end
  end

  @sample_report_output """
  =====> my-app git information
         Git deploy branch:           main
         Git global deploy branch:    master
         Git keep git dir:            false
         Git rev env var:             GIT_REV
         Git sha:                     abc123def456
         Git source image:
         Git last updated at:         1713225600
  """

  describe "report/1" do
    test "returns {:ok, report} on success" do
      expect(
        DokkuRemote.Dokku.Command.App.Mock,
        :run,
        fn _app, "git:report" ->
          {:ok, @sample_report_output}
        end
      )

      {:ok, report} =
        App.report(app())

      assert report ==
               %DokkuRemote.Commands.Git.Report{
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

    test "returns {:error, output, exit_code} on failure" do
      expect(
        DokkuRemote.Dokku.Command.App.Mock,
        :run,
        fn _app, "git:report" ->
          {:error, "App my-app does not exist", 1}
        end
      )

      assert App.report(app()) == {:error, "App my-app does not exist", 1}
    end
  end
end
