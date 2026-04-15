import Config

config :dokku_remote,
  System: DokkuRemote.System.Mock,
  "DokkuRemote.AppCommand": DokkuRemote.AppCommand.Mock,
  "DokkuRemote.Dokku.Command": DokkuRemote.Dokku.Command.Mock
