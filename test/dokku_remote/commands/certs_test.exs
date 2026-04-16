defmodule DokkuRemote.Commands.CertsTest do
  use ExUnit.Case, async: true

  import Mox

  alias DokkuRemote.Commands.Certs
  alias DokkuRemote.Commands.Certs.Report

  setup :verify_on_exit!

  @dokku_host "dokku.example.com"

  @sample_output """
  =====> my-app ssl information
         Ssl dir:                       /home/dokku/my-app/tls
         Ssl enabled:                   true
         Ssl hostnames:                 my-app.example.com
         Ssl expires at:                Jul  1 08:39:08 2026 GMT
         Ssl issuer:                    C = US, O = Let's Encrypt, CN = E8
         Ssl starts at:                 Apr  2 08:39:09 2026 GMT
         Ssl subject:                   subject=CN = my-app.example.com
         Ssl verified:                  verified by a certificate authority
  =====> other-app ssl information
         Ssl dir:                       /home/dokku/other-app/tls
         Ssl enabled:                   false
         Ssl hostnames:                 other-app.example.com
         Ssl expires at:                Jun 30 14:42:25 2026 GMT
         Ssl issuer:                    C = US, O = Let's Encrypt, CN = E8
         Ssl starts at:                 Apr  1 14:42:26 2026 GMT
         Ssl subject:                   subject=CN = other-app.example.com
         Ssl verified:                  verified by a certificate authority
  """

  describe "report/1" do
    test "returns {:ok, map} with parsed reports on success" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "certs:report" ->
        {:ok, @sample_output}
      end)

      assert {:ok, reports} = Certs.report(@dokku_host)

      assert %Report{
               app_name: "my-app",
               dir: "/home/dokku/my-app/tls",
               enabled: true,
               hostnames: "my-app.example.com",
               expires_at: "Jul  1 08:39:08 2026 GMT",
               issuer: "C = US, O = Let's Encrypt, CN = E8",
               starts_at: "Apr  2 08:39:09 2026 GMT",
               subject: "subject=CN = my-app.example.com",
               verified: "verified by a certificate authority"
             } = reports["my-app"]

      assert %Report{
               app_name: "other-app",
               dir: "/home/dokku/other-app/tls",
               enabled: false,
               hostnames: "other-app.example.com",
               expires_at: "Jun 30 14:42:25 2026 GMT",
               issuer: "C = US, O = Let's Encrypt, CN = E8",
               starts_at: "Apr  1 14:42:26 2026 GMT",
               subject: "subject=CN = other-app.example.com",
               verified: "verified by a certificate authority"
             } = reports["other-app"]
    end

    test "returns {:ok, empty map} when output is empty" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "certs:report" ->
        {:ok, ""}
      end)

      assert Certs.report(@dokku_host) == {:ok, %{}}
    end

    test "returns {:error, output, exit_code} on failure" do
      expect(DokkuRemote.Dokku.Command.Mock, :run, fn "dokku.example.com", "certs:report" ->
        {:error, "connection refused", 1}
      end)

      assert Certs.report(@dokku_host) == {:error, "connection refused", 1}
    end
  end
end
