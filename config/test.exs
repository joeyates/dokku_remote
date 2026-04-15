import Config

config :dokku_remote,
  System: DokkuRemote.System.Mock,
  "DokkuRemote.Dokku.Command": DokkuRemote.Dokku.Command.Mock,
  "DokkuRemote.Dokku.Command.App": DokkuRemote.Dokku.Command.App.Mock
