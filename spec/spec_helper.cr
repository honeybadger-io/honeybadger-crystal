require "spec"
require "../src/honeybadger"

require "./support/example_payload"
require "./support/mock_http"
require "./support/protect_configuration"
require "./support/protect_environment"

def example_payload
  Honeybadger::ExamplePayload.new Exception.new
end
