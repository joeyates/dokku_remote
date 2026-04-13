---
title: Add Tests
description: Add ExUnit test coverage for all modules using Mox for mocking.
branch: feature/add-tests
---

## Overview

Add ExUnit test coverage for all modules using Mox for mocking. Mocks live in `test/support/mocks.ex`; compile-time mock selection is configured via `config/test.exs`.

## Tasks

- [x] 1. Add `mox` to test/dev deps in `mix.exs`; add `elixirc_paths/1` to include `test/support` in the `:test` env compilation paths; create `config/config.exs` and `config/test.exs` and wire them up via `config_path` in `mix.exs`; create `test/support/mocks.ex` (initially empty); update `test/test_helper.exs` to import mocks.
- [x] 2. Test `AppCommand`: add `DokkuRemote.Shell` behaviour (with `@callback` before each relevant `def`) and `DokkuRemote.System` default implementation; use `Application.compile_env` in `AppCommand` to select the shell; declare `DokkuRemote.Shell.Mock` in `test/support/mocks.ex`; add config entry in `config/test.exs`; write tests.
- [ ] 3. Test `Commands.Apps.App`: add `AppCommand` behaviour (with `@callback` before each relevant `def`); use `Application.compile_env` in `Commands.Apps.App`; declare `DokkuRemote.AppCommand.Mock` in `test/support/mocks.ex`; add config entry; write tests.
- [ ] 4. Test `Commands.Config.App`: use `Application.compile_env` and `DokkuRemote.AppCommand.Mock`; write tests.
- [ ] 5. Test `Commands.Domains.App`: use `Application.compile_env` and `DokkuRemote.AppCommand.Mock`; write tests.
- [ ] 6. Test `Commands.Letsencrypt.App`: use `Application.compile_env` and `DokkuRemote.AppCommand.Mock`; write tests.
- [ ] 7. Test `Commands.Ports.App`: use `Application.compile_env` and `DokkuRemote.AppCommand.Mock`; write tests.
- [ ] 8. Ask the user for feedback on the state of the implementation and carry out any requested corrections.
- [ ] 9. Mark the plan as "done".

## Principal Files

- `mix.exs`
- `config/config.exs`
- `config/test.exs`
- `test/support/mocks.ex`
- `test/test_helper.exs`
- `lib/dokku_remote/app_command.ex`
- `lib/dokku_remote/commands/apps/app.ex`
- `lib/dokku_remote/commands/config/app.ex`
- `lib/dokku_remote/commands/domains/app.ex`
- `lib/dokku_remote/commands/letsencrypt/app.ex`
- `lib/dokku_remote/commands/ports/app.ex`

## Acceptance Criteria

- `mix test` passes with no failures.
- All public functions in `AppCommand` and the five command modules have tests covering the happy path and error/edge cases.
- No test makes real SSH calls.
- Mocks are configured via `config/test.exs` using `Application.compile_env`.
