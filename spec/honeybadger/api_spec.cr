require "../spec_helper"

describe Honeybadger::Api do
  describe "#request_headers" do
    headers = Honeybadger::Api.new(example_payload).request_headers
    headers["Content-Type"].should eq "application/json"
    headers["X-API-Key"].should eq test_api_key

    headers["User-Agent"].should match /^Crystal #{Crystal::VERSION}/
    headers["User-Agent"].should match /#{Honeybadger::VERSION}/
  end
end
