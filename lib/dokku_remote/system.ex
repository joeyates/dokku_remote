defmodule DokkuRemote.System do
  @callback shell(command :: String.t(), opts :: keyword()) :: {String.t(), non_neg_integer()}
end
