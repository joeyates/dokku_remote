defmodule DokkuRemote.Commands.Git.Report do
  @keys [
    :app_name,
    :deploy_branch,
    :global_deploy_branch,
    :keep_git_dir,
    :rev_env_var,
    :sha,
    :source_image,
    :last_updated_at
  ]
  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          app_name: String.t(),
          deploy_branch: String.t(),
          global_deploy_branch: String.t(),
          keep_git_dir: boolean(),
          rev_env_var: String.t(),
          sha: String.t(),
          source_image: String.t(),
          last_updated_at: non_neg_integer()
        }
end
