defmodule DokkuRemote.Commands.Certs.Report do
  @required_keys [
    :app_name,
    :dir,
    :enabled
  ]
  @optional_keys [
    :hostnames,
    :expires_at,
    :issuer,
    :starts_at,
    :subject,
    :verified
  ]
  @enforce_keys @required_keys
  defstruct @required_keys ++ @optional_keys

  @type t :: %__MODULE__{
          app_name: String.t(),
          dir: String.t(),
          enabled: boolean(),
          hostnames: String.t(),
          expires_at: String.t(),
          issuer: String.t(),
          starts_at: String.t(),
          subject: String.t(),
          verified: String.t()
        }
end
