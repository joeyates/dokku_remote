defmodule DokkuRemote.Root.CopyTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Root.Copy

  setup :verify_on_exit!

  describe "to_host/3" do
    test "calls scp with the correct args" do
      expect(DokkuRemote.System.Mock, :cmd, fn program, args, _opts ->
        assert program == "scp"
        assert args == ["local/path/file.txt", "root@dokku.example.com:/remote/path/file.txt"]
        {"", 0}
      end)

      Copy.to_host("dokku.example.com", "local/path/file.txt", "/remote/path/file.txt")
    end

    test "returns {:ok, output} on success" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts -> {"", 0} end)

      assert Copy.to_host("dokku.example.com", "local/file.txt", "/remote/file.txt") ==
               {:ok, ""}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.System.Mock, :cmd, fn _prog, _args, _opts ->
        {"scp: /remote/file.txt: Permission denied", 1}
      end)

      assert Copy.to_host("dokku.example.com", "local/file.txt", "/remote/file.txt") ==
               {:error, "scp: /remote/file.txt: Permission denied", 1}
    end
  end
end
