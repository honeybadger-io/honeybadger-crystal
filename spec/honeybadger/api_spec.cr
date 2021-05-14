require "../spec_helper"

describe Honeybadger::Api do
  it "implements correct request headers" do
    protect_configuration do
      test_api_key = "2468"
      Honeybadger.configuration.api_key = test_api_key
      headers = Honeybadger::Api.new.request_headers

      headers["Content-Type"].should eq "application/json"
      headers["X-API-Key"].should eq test_api_key

      headers["User-Agent"].should match /^Crystal #{Crystal::VERSION}/
      headers["User-Agent"].should match /#{Honeybadger::VERSION}/
    end
  end
end
