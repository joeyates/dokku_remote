defmodule DokkuRemote.System do
  @callback cmd(program :: String.t(), args :: [String.t()], opts :: keyword()) ::
              {String.t(), non_neg_integer()}
end
