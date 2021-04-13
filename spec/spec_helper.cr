require "spec"
require "../src/honeybadger"

require "./support/example_payload"
require "./support/mock_http"
require "./support/configuration_isolater"

def example_payload
  Honeybadger::ExamplePayload.new Exception.new
end

def test_api_key
  "123456abc"
end

Honeybadger.configure api_key: test_api_key
