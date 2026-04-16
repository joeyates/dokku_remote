---
title: Implement Missing Dokku Calls
description: Add seven new Dokku command wrappers — certs:report, ps:scale, plugin:list, postgres:list, postgres:links, redis:list, redis:links — with structs where output is structured.
branch: feature/implement-missing-dokku-calls
---

## Overview

Implement the remaining Dokku command wrappers listed in the TODO. Each call follows the established pattern: a module under `DokkuRemote.Commands.*` delegating to `@command_impl` (i.e. `DokkuRemote.Dokku.Command`). Where output is structured and multi-field, a companion `Report`/`Entry`/`Scale` struct is defined (following the `DokkuRemote.Commands.Git.Report` precedent). Each call is implemented TDD-style — tests written first with anonymized inline fixtures derived from the example files in the project root — then committed individually after `mix test <file>` and `mix format` both pass.

## Tasks

- [x] 1. `certs:report` — Create `DokkuRemote.Commands.Certs.Report` struct (fields: `app_name`, `dir`, `enabled :: boolean()`, `hostnames`, `expires_at`, `issuer`, `starts_at`, `subject`, `verified`). Create `DokkuRemote.Commands.Certs` with `report/1` returning `{:ok, %{String.t() => Certs.Report.t()}}`. Parse multi-app output following the `git.ex` pattern. Use an anonymized inline fixture derived from `certs-report-example.txt`. Run `mix test test/dokku_remote/commands/certs_test.exs`, then `mix format`; commit.
- [x] 2. `ps:scale` — Create `DokkuRemote.Commands.Ps.Scale` struct (fields: `app_name`, `proctypes :: %{String.t() => non_neg_integer()}`). Create `DokkuRemote.Commands.Ps` with `scale/1` (all apps → `{:ok, %{String.t() => Ps.Scale.t()}}`) and `scale/2` (specific app → `{:ok, Ps.Scale.t()}`). Use an anonymized inline fixture derived from `ps-scale-app-example.txt`. Run `mix test test/dokku_remote/commands/ps_test.exs`, then `mix format`; commit.
- [x] 3. `plugin:list` — Create `DokkuRemote.Commands.Plugin.Entry` struct (fields: `name`, `version`, `enabled :: boolean()`, `description`). Create `DokkuRemote.Commands.Plugin` with `list/1` returning `{:ok, [Plugin.Entry.t()]}`. Use an anonymized inline fixture derived from `plugin-list-example.txt`. Run `mix test test/dokku_remote/commands/plugin_test.exs`, then `mix format`; commit.
- [x] 4. `postgres:list` — Create `DokkuRemote.Commands.Postgres` with `list/1` returning `{:ok, [String.t()]}`. Use an anonymized inline fixture derived from `postgres-list-example.txt`. Run `mix test test/dokku_remote/commands/postgres_test.exs`, then `mix format`; commit.
- [x] 5. `postgres:links` — Extend `DokkuRemote.Commands.Postgres` with `links/2` taking `(dokku_host, service)` and returning `{:ok, [String.t()]}`. Use an anonymized inline fixture derived from `postgres-links-example.txt`. Run `mix test test/dokku_remote/commands/postgres_test.exs`, then `mix format`; commit.
- [x] 6. `redis:list` — Create `DokkuRemote.Commands.Redis` with `list/1` returning `{:ok, [String.t()]}`. Use an anonymized inline fixture derived from `redis-list-example.txt`. Run `mix test test/dokku_remote/commands/redis_test.exs`, then `mix format`; commit.
- [x] 7. `redis:links` — Extend `DokkuRemote.Commands.Redis` with `links/2` taking `(dokku_host, service)` and returning `{:ok, [String.t()]}`. Use an anonymized inline fixture derived from `redis-links-example.txt`. Run `mix test test/dokku_remote/commands/redis_test.exs`, then `mix format`; commit.
- [x] 8. Run `mix test` (full suite) to confirm no regressions.
- [ ] 9. Ask the user for feedback on the state of the implementation and carry out any requested corrections.
- [ ] 10. Mark the plan as "done".

## Principal Files

- `lib/dokku_remote/commands/certs.ex`
- `lib/dokku_remote/commands/certs/report.ex`
- `test/dokku_remote/commands/certs_test.exs`
- `lib/dokku_remote/commands/ps.ex`
- `lib/dokku_remote/commands/ps/scale.ex`
- `test/dokku_remote/commands/ps_test.exs`
- `lib/dokku_remote/commands/plugin.ex`
- `lib/dokku_remote/commands/plugin/entry.ex`
- `test/dokku_remote/commands/plugin_test.exs`
- `lib/dokku_remote/commands/postgres.ex`
- `test/dokku_remote/commands/postgres_test.exs`
- `lib/dokku_remote/commands/redis.ex`
- `test/dokku_remote/commands/redis_test.exs`

## Acceptance Criteria

- All seven Dokku calls (`certs:report`, `ps:scale`, `plugin:list`, `postgres:list`, `postgres:links`, `redis:list`, `redis:links`) are implemented.
- Each was committed separately in a green + formatted state.
- Structured outputs (`certs:report`, `ps:scale`, `plugin:list`) return typed structs.
- `mix test` passes with no failures.
- `mix format --check-formatted` passes.
