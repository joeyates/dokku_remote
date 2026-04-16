---
title: Centralize SSH Calls via Ssh Module
description: Refactor Dokku.Command, Root.Command, and Dokku.Command.App to delegate all SSH invocations to DokkuRemote.Ssh instead of calling System.cmd directly.
branch: feature/centralize-ssh-calls
status: in-progress
---

## Overview

Three modules currently call `@system_impl.cmd("ssh", ...)` directly: `Dokku.Command`, `Root.Command`, and `Dokku.Command.App`. The `DokkuRemote.Ssh` module already centralizes SSH logic (per-host/per-user key config, verbose streaming). Each module should be refactored to delegate to `Ssh.run/5` instead. Changes are made one module at a time using TDD, with a test + format pass before each commit.

Callers of `Dokku.Command` and `Dokku.Command.App` (e.g. `network.ex`, command modules) are unaffected — they already mock those modules.

## Tasks

- [ ] 1. Add `Mox.defmock(DokkuRemote.Ssh.Mock, for: DokkuRemote.Ssh)` to `test/support/mocks.ex`; add `Ssh: DokkuRemote.Ssh.Mock` to `config/test.exs`.
- [ ] 2. Update `test/dokku_remote/dokku/command_test.exs` to expect `Ssh.Mock.run(host, "dokku", command, params, opts)` instead of `System.Mock.cmd/3`; update `lib/dokku_remote/dokku/command.ex` to use `@ssh_impl` and call `@ssh_impl.run(dokku_host, "dokku", command, params, opts)`; run `mix test test/dokku_remote/dokku/command_test.exs`, then `mix format`; commit.
- [ ] 3. Update `test/dokku_remote/root/command_test.exs` to expect `Ssh.Mock.run(host, "root", command, params, opts)`; update `lib/dokku_remote/root/command.ex` to call `@ssh_impl.run(dokku_host, "root", command, params, opts)`; run `mix test test/dokku_remote/root/command_test.exs`, then `mix format`; commit.
- [ ] 4. Update `test/dokku_remote/dokku/command/app_test.exs` to expect `Ssh.Mock.run(host, "dokku", command, [app.dokku_app | params], verbose: app.verbose)`; update `lib/dokku_remote/dokku/command/app.ex` to call `@ssh_impl.run(app.dokku_host, "dokku", command, [app.dokku_app | params], verbose: app.verbose)`; run `mix test test/dokku_remote/dokku/command/app_test.exs`, then `mix format`; commit.
- [ ] 5. Run `mix test` (full suite) to confirm no regressions.
- [ ] 6. Ask the user for feedback and carry out any requested corrections.
- [ ] 7. Mark the plan as "done".

## Principal Files

- `test/support/mocks.ex`
- `config/test.exs`
- `lib/dokku_remote/dokku/command.ex`
- `test/dokku_remote/dokku/command_test.exs`
- `lib/dokku_remote/root/command.ex`
- `test/dokku_remote/root/command_test.exs`
- `lib/dokku_remote/dokku/command/app.ex`
- `test/dokku_remote/dokku/command/app_test.exs`

## Acceptance Criteria

- `mix test` passes with no failures.
- `Dokku.Command`, `Root.Command`, and `Dokku.Command.App` contain no direct `System.cmd` calls.
- All three modules use `Application.compile_env(:dokku_remote, :Ssh, DokkuRemote.Ssh)` for SSH dispatch.
- Tests for each module use `Ssh.Mock` expectations, not `System.Mock`.