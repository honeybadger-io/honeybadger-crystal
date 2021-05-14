# Honeybadger for Crystal
[![Crystal CI](https://github.com/honeybadger-io/honeybadger-crystal/actions/workflows/crystal.yml/badge.svg)](https://github.com/honeybadger-io/honeybadger-crystal/actions/workflows/crystal.yml)

`HTTP::Handler` and exception notifier for the :zap: [Honeybadger error notifier](https://www.honeybadger.io/).

## Getting Started

Update your `shard.yml` to include honeybadger:

```diff
dependencies:
+  honeybadger:
+    github: honeybadger-io/honeybadger-crystal
```

Configure your API key (available under Project Settings in Honeybadger):

```crystal
Honeybadger.configure do |config|
  config.api_key = ENV["HONEYBADGER_API_KEY"]? || "API Key"
  config.environment = ENV["HONEYBADGER_ENVIRONMENT"]? || "production"
end
```

### Reporting Errors

If you're using a web framework, add the `Honeybadger::Handler` to the `HTTP::Server` stack:

```crystal
HTTP::Server.new([Honeybadger::Handler.new]) do |context|
  # ...
end
```

Details for adding the handler to:

- [Lucky Framework](https://luckyframework.org/guides/http-and-routing/http-handlers)
- [Amber Framework](https://docs.amberframework.org/amber/guides/routing/pipelines#sharing-pipelines)

For non-web contexts, or to manually report exceptions to Honeybadger, use `Honeybadger.notify`:

```crystal
begin
  # run application code
  raise "OH NO!"
rescue exception
  Honeybadger.notify(exception)
end
```

## Configuration

To set configuration options, use the `Honeybadger.configure` method:

```crystal
Honeybadger.configure do |config|
  config.api_key = "API Key"
  config.environment = "production"
end
```

The following configuration options are available:

|  Name | Type | Default | Example | Environment Var |
| ----- | ---- | ------- | ------- | --------------- |
| api_key | String | `""` | `"badgers"` | HONEYBADGER_API_KEY |
| endpoint | Path|String | `"https://api.honeybadger.io"` | `"https://honeybadger.example.com/"` | HONEYBADGER_ENDPOINT |
| hostname | String | The hostname of the current server. | `"badger"` | HONEYBADGER_HOSTNAME |
| project_root | String | The current working directory | `"/path/to/project"` | HONEYBADGER_PROJECT_ROOT |
| report_data | `bool` | `true` | `false` | HONEYBADGER_REPORT_DATA |
| development_environments | Array(String) | ["development","test"] | | HONEYBADGER_DEVELOPMENT_ENVIRONMENTS |
| environment | String? | `nil` | `"production"` | HONEYBADGER_ENVIRONMENT |

### Environment based config

Honeybadger can also be configured from environment variables. Each variable has a correlated environment variable and is prefixed with `HONEYBADGER_`. For example:

```
env HONEYBADGER_API_KEY=2468 ./server
```

All environment variables are documented in the configuration table above.

## Version Requirements

Crystal > 0.36.1

## Development

The packaged demo app creates a minimal http server which responds to `/raise` by generating an exception.

To run the demo app, raise an exception, and send it to the honeybadger API:

- `HONEYBADGER_API_KEY=nnnnnnnn script/demo`
