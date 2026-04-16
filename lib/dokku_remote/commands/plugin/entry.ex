defmodule DokkuRemote.Commands.Plugin.Entry do
  @keys [:name, :version, :enabled, :description]
  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          version: String.t(),
          enabled: boolean(),
          description: String.t()
        }
end
