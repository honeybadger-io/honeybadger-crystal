require "spec"
require "../src/honeybadger"

require "./support/example_payload"

def example_payload
  Honeybadger::ExamplePayload.new
end

def test_api_key
  "123456abc"
end

Honeybadger.configure api_key: test_api_key
