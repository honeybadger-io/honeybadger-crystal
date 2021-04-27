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

Add the `Honeybadger::Handler` to the `HTTP::Server` stack:

```crystal
honeybadger_api_key = ENV["HONEYBADGER_API_KEY"]? || "00000000"

Honeybadger.configure(api_key: honeybadger_api_key)

HTTP::Server.new([Honeybadger::Handler.new]) do |context|
  # ...
end
```

Details for adding the handler to:

- [Lucky Framework](https://luckyframework.org/guides/http-and-routing/http-handlers)
- [Amber Framework](https://docs.amberframework.org/amber/guides/routing/pipelines#sharing-pipelines)

### Reporting exceptions

For non-web contexts, manually report exceptions to Honeybadger like so:

```crystal
begin
  # run application code
  raise "OH NO!"
rescue exception
  Honeybadger.notify(exception)
end
```

## Configuration

To set configuration options, use the `Honeybadger.configure` method. For the default, out of the box configuration, provide the API key:

```crystal
Honeybadger.configure("your api key")
```

For more configuration options, you can get access to the entire configuration object with a block:

```crystal
Honeybadger.configure do |settings|
  settings.api_key = "your api key"
  settings.hostname = "badger"
end
```

The following configuration options are available:

|  Name | Type | Default | Example |
| ----- | ---- | ------- | ------- |
| api_key | String | `""` | `"badgers"` |
| endpoint | Path|String | `"https://api.honeybadger.io"` | `"https://honeybadger.example.com/"` |
| hostname | String | The hostname of the current server. | `"badger"` |
| project_root | String | The current working directory | `"/path/to/project"` |
| report_data | `bool` | `true` | `false` |
| development_environment | Array(String) | ["development","test"] | |
| environment | String | `"production"` | |

## Version Requirements

Crystal > 0.36.1

## Development

The packaged demo app creates a minimal http server which responds to `/raise` by generating an exception.

To run the demo app, raise an exception, and send it to the honeybadger API:

- `HONEYBADGER_API_KEY=nnnnnnnn script/demo`
