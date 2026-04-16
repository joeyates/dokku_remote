defmodule DokkuRemote.Dokku.Command.App do
  alias DokkuRemote.App

  @ssh_impl Application.compile_env(:dokku_remote, :Ssh, DokkuRemote.Ssh)

  @callback run(app :: %App{}, command :: String.t()) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(app :: %App{}, command :: String.t(), params :: [String.t()]) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}

  def run(%App{} = app, command, params \\ []) do
    @ssh_impl.run(app.dokku_host, "dokku", command, [app.dokku_app | params],
      verbose: app.verbose
    )
  end
end
