---
title: Implement Missing Functions
description: Implement the missing Dokku command modules for docker-options, enter, git, logs, network, proxy, ps, and storage.
branch: feature/implement-missing-functions
---

## Overview

Implement missing Dokku command modules. Each command namespace gets its own module under `lib/dokku_remote/commands/`. Tests are written alongside implementation using `DokkuRemote.AppCommand.Mock`, following the existing patterns established in the `Commands.Apps.App`, `Commands.Config.App`, etc. modules.

> **Note**: To inspect Dokku command help and discover output formats, use `ssh dokku@$DOKKU_HOST COMMAND` (e.g. `ssh dokku@$DOKKU_HOST help` or `ssh dokku@$DOKKU_HOST ps:report myapp`). Do **not** run destructive commands when exploring help output.

Note: `apps:create` is already implemented in `DokkuRemote.Commands.Apps.App` and can be skipped.

## Tasks

- [x] 1. Implement `DokkuRemote.Commands.DockerOptions.App` with `add/3` (`docker-options:add APP PHASE OPTION`); write tests.
- [x] 2. Implement `DokkuRemote.Commands.Git.App` with `from_image/2` (`git:from-image APP IMAGE`); write tests.
- [x] 3. Implement `DokkuRemote.Commands.Logs.App` with `get/1` (and optional opts such as `n:`, `tail:`, `process_type:`); write tests.
- [ ] 4. Implement `DokkuRemote.Commands.Network.App` with `report/1` and `set/3` (`network:report APP`, `network:set APP PROPERTY VALUE`); write tests.
- [ ] 5. Implement `DokkuRemote.Commands.Proxy.App` with `disable/1` (`proxy:disable APP`); write tests.
- [ ] 6. Implement `DokkuRemote.Commands.Ps.App` with `rebuild/1`, `report/1`, `restart/1`, `stop/1`; write tests.
- [ ] 7. Implement `DokkuRemote.Commands.Storage.App` with `ensure_directory/2` (`storage:ensure-directory APP DIR`) and `mount/3` (`storage:mount APP HOST_DIR:CONTAINER_DIR`); write tests.
- [ ] 8. Implement `DokkuRemote.Commands.Enter` with `run/1` (`enter APP`); this is an interactive command — note any constraints on how it fits the existing `AppCommand` pattern; write tests.
- [ ] 9. Ask the user for feedback on the state of the implementation and carry out any requested corrections.
- [ ] 10. Mark the plan as "done".

## Principal Files

- `lib/dokku_remote/commands/docker_options/app.ex`
- `test/dokku_remote/commands/docker_options/app_test.exs`
- `lib/dokku_remote/commands/git/app.ex`
- `test/dokku_remote/commands/git/app_test.exs`
- `lib/dokku_remote/commands/logs/app.ex`
- `test/dokku_remote/commands/logs/app_test.exs`
- `lib/dokku_remote/commands/network/app.ex`
- `test/dokku_remote/commands/network/app_test.exs`
- `lib/dokku_remote/commands/proxy/app.ex`
- `test/dokku_remote/commands/proxy/app_test.exs`
- `lib/dokku_remote/commands/ps/app.ex`
- `test/dokku_remote/commands/ps/app_test.exs`
- `lib/dokku_remote/commands/storage/app.ex`
- `test/dokku_remote/commands/storage/app_test.exs`
- `lib/dokku_remote/commands/enter.ex`
- `test/dokku_remote/commands/enter_test.exs`

## Acceptance Criteria

- `mix test` passes with no failures.
- All new command modules have tests covering happy path and error/edge cases.
- No test makes real SSH calls.
- Each module uses `Application.compile_env` for `AppCommand` selection, consistent with existing modules.
