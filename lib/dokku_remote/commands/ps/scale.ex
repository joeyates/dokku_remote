defmodule DokkuRemote.Commands.Ps.Scale do
  @keys [:app_name, :proctypes]
  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          app_name: String.t(),
          proctypes: %{String.t() => non_neg_integer()}
        }
end
