defmodule DokkuRemote.App do
  @moduledoc """
  Represents a Dokku application and its connection details.
  """
  @required_keys [:dokku_app, :dokku_host]
  @enforce_keys @required_keys
  defstruct @required_keys ++ [verbose: false]

  @type t :: %__MODULE__{
          dokku_app: String.t(),
          dokku_host: String.t(),
          verbose: boolean()
        }

  def new(opts) do
    struct!(__MODULE__, opts)
  end
end
