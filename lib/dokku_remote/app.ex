defmodule DokkuRemote.App do
  @required_keys [:dokku_app, :dokku_host]
  @enforce_keys @required_keys
  defstruct @required_keys ++ [verbose: false]

  def new(opts) do
    struct!(__MODULE__, opts)
  end
end
