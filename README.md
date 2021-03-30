# Honeybadger for Crystal

`HTTP::Handler` and exception notifier for the :zap: [Honeybadger error notifier](https://www.honeybadger.io/).

## Getting Started

Update your `shard.yml` to include honeybadger:

```diff
dependencies:
+  honeybadger:
+    github: honeybadger-io/honeybadger-crystal
```

Add the Honeybadger::Handler to the `HTTP::Server` stack:

```crystal
honeybadger_api_key = ENV["HONEYBADGER_API_KEY"]? || "00000000"
honeybadger_enabled = MyServer.production?

Honeybadger.configure(api_key: honeybadger_api_key)

Honeybadger::Handler.new(
  enabled: honeybadger_enabled,
  factory: Honeybadger::Payload
)
```

Details for adding the handler to:

- [Lucky Framework](https://luckyframework.org/guides/http-and-routing/http-handlers)
- [Amber Framework](https://docs.amberframework.org/amber/guides/routing/pipelines#sharing-pipelines)

## Version Requirements

Crystal > 0.36.1

## Development

The packaged demo app creates a minimal http server which responds to `/raise` by generating an exception.

To run the demo app, raise an exception, and send it to the honeybadger API:

- `HONEYBADGER_API_KEY=nnnnnnnn script/demo`
