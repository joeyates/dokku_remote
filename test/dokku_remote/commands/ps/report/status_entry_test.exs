defmodule DokkuRemote.Commands.Ps.Report.StatusEntryTest do
  use ExUnit.Case, async: true

  alias DokkuRemote.Commands.Ps.Report.StatusEntry

  describe "from_line/1" do
    test "parses a valid line with CID" do
      line = "Status web 1: running (CID: 1fb72325e15)"
      {:ok, status_entry} = StatusEntry.from_line(line)

      assert status_entry == %StatusEntry{
               process_name: "web",
               index: 1,
               running: true,
               cid: "1fb72325e15"
             }
    end

    test "parses a valid line without CID" do
      line = "Status worker 2: stopped"
      {:ok, status_entry} = StatusEntry.from_line(line)

      assert status_entry == %StatusEntry{
               process_name: "worker",
               index: 2,
               running: false,
               cid: nil
             }
    end

    test "returns an error for an invalid line" do
      line = "Invalid status line"
      assert {:error, :invalid_line_format} == StatusEntry.from_line(line)
    end
  end
end
