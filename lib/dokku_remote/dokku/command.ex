defmodule DokkuRemote.Dokku.Command do
  @ssh_impl Application.compile_env(:dokku_remote, :Ssh, DokkuRemote.Ssh)

  @callback run(dokku_host :: String.t(), command :: String.t()) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(dokku_host :: String.t(), command :: String.t(), params :: [String.t()]) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}
  @callback run(
              dokku_host :: String.t(),
              command :: String.t(),
              params :: [String.t()],
              opts :: Keyword.t()
            ) ::
              {:ok, String.t()} | {:error, String.t(), non_neg_integer()}

  def run(dokku_host, command, params \\ [], opts \\ []) do
    @ssh_impl.run(dokku_host, "dokku", command, params, opts)
  end
end
