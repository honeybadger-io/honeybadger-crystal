# Honeybadger for Crystal
[![Crystal CI](https://github.com/honeybadger-io/honeybadger-crystal/actions/workflows/crystal.yml/badge.svg)](https://github.com/honeybadger-io/honeybadger-crystal/actions/workflows/crystal.yml)

`HTTP::Handler` and exception notifier for the :zap: [Honeybadger error notifier](https://www.honeybadger.io/).

## Resources

The change log for this shard is included in this repository: https://github.com/honeybadger-io/honeybadger-crystal/blob/main/CHANGELOG.md

## Getting Started

### Installation

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

#### Reporting Errors in Web Frameworks

If you're using a web framework, add the `Honeybadger::Handler` to the `HTTP::Server` stack:

```crystal
HTTP::Server.new([Honeybadger::Handler.new]) do |context|
  # ...
end
```

Details for adding the handler to:

##### Reporting errors in [Lucky Framework](https://luckyframework.org)

1. Add the shard to `shard.yml`
2. Require the shard in `src/shards.cr`
3. Add the built-in `Honeybadger::AuthenticHandler` to your middleware stack:

    ```crystal
    def middleware : Array(HTTP::Handler)
      [
        # ...
        Lucky::ErrorHandler.new(action: Errors::Show),
        Honeybadger::AuthenticMiddleware.new,
        # ...
      ] of HTTP::Handler
    end
    ```

Read more about HTTP Handlers in Lucky [here](https://luckyframework.org/guides/http-and-routing/http-handlers).

##### Reporting errors in [Amber Framework](https://amberframework.org)

Read more about Pipelines in Amber [here](https://docs.amberframework.org/amber/guides/routing/pipelines#sharing-pipelines).

#### Reporting Errors Manually

For non-web contexts, or to manually report exceptions to Honeybadger, use `Honeybadger.notify`:

```crystal
begin
  # run application code
  raise "OH NO!"
rescue exception
  Honeybadger.notify(exception)
end
```

### Identifying Users

Honeybadger can track what users have encountered each error. To identify the current user in error reports, add a user identifier and/or email address to Honeybadger's `context` hash:

```crystal
# Explicit Context
Honeybadger.notify(exception, context: {
  "user_id" => user.id,
  "user_email" => "user@example.com"
})

# Managed Context
Honeybadger.context(user_id: user.id)
```

For an example of identifying users in HTTP handlers, see [demo/http_context.cr](https://github.com/honeybadger-io/honeybadger-crystal/blob/main/demo/http_context.cr)

[Learn more about context data in Honeybadger](https://docs.honeybadger.io/guides/errors/#context-data)

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
| endpoint | Path\|String | `"https://api.honeybadger.io"` | `"https://honeybadger.example.com/"` | HONEYBADGER_ENDPOINT |
| hostname | String | The hostname of the current server. | `"badger"` | HONEYBADGER_HOSTNAME |
| project_root | String | The current working directory | `"/path/to/project"` | HONEYBADGER_PROJECT_ROOT |
| report_data | `bool` | `true` | `false` | HONEYBADGER_REPORT_DATA |
| development_environments | Array(String) | ["development","test"] | | HONEYBADGER_DEVELOPMENT_ENVIRONMENTS |
| environment | String? | `nil` | `"production"` | HONEYBADGER_ENVIRONMENT |
| merge_log_context | `bool` | `true` | `false` | n/a |

Documentation for context variables can be found [in the Configuration class](https://github.com/honeybadger-io/honeybadger-crystal/blob/main/src/honeybadger/configuration.cr)

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
