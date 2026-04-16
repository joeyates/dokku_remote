# Development

## Testing

Run the full test suite:

```
mix test
```

Run a single file:

```
mix test test/dokku_remote/ssh_test.exs
```

### Approach

Tests follow a TDD style. Each public function is tested through its public interface; implementation details are not tested directly.

### Mocks

External dependencies are replaced with mocks in the test environment. Mocks are defined with [Mox](https://hexdocs.pm/mox) in [test/support/mocks.ex](../test/support/mocks.ex) and activated via `config/test.exs`.

Every test module that uses mocks must include:

```elixir
import Mox
setup :verify_on_exit!
```

`verify_on_exit!` ensures that every mock expectation set with `expect/3` is actually called, catching unused stubs that would otherwise silently pass.

### Application config in tests

Tests that modify `Application` env must clean up after themselves. Use an `on_exit` callback to restore the previous value (or delete the key if it was absent before the test):

```elixir
defp put_ssh_config(config) do
  previous = Application.get_env(:dokku_remote, DokkuRemote.Ssh)
  Application.put_env(:dokku_remote, DokkuRemote.Ssh, config)

  on_exit(fn ->
    if previous == nil do
      Application.delete_env(:dokku_remote, DokkuRemote.Ssh)
    else
      Application.put_env(:dokku_remote, DokkuRemote.Ssh, previous)
    end
  end)
end
```

Any test module that modifies `Application` env must also set `async: false`, because `Application` env is global and concurrent tests would interfere with each other.
