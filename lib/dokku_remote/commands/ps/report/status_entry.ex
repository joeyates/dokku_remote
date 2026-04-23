defmodule DokkuRemote.Commands.Ps.Report.StatusEntry do
  @keys [:process_name, :index, :running, :cid]
  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          process_name: String.t(),
          index: non_neg_integer(),
          running: boolean(),
          cid: String.t() | nil
        }

  def from_line(line) do
    # Example line: "Status web 1: running (CID: 1fb72325e15)"
    regex = ~r/Status\s+(\w+)\s+(\d+):\s+(\w+)(?:\s+\(CID:\s+([a-f0-9]+)\))?/

    case Regex.run(regex, line) do
      [_, process_name, index_str, status | rest] ->
        index = String.to_integer(index_str)
        cid = List.first(rest)
        running = status == "running"

        {
          :ok,
          %__MODULE__{
            process_name: process_name,
            index: index,
            running: running,
            cid: cid
          }
        }

      _ ->
        {:error, :invalid_line_format}
    end
  end
end
