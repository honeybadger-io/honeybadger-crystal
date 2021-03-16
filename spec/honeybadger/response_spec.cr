require "../spec_helper"

describe Honeybadger::Response do
  it "checks for success" do
    Honeybadger::Response.new(MockHttp.client_response).success?.should be_true
    Honeybadger::Response.new(MockHttp.client_response(HTTP::Status::BAD_REQUEST)).success?.should be_false
  end

  it "parses the response id" do
    mock_json = {id: "12345"}
    http_response = MockHttp.client_response(body: mock_json.to_json)
    Honeybadger::Response.new(http_response).parsed_id.should eq "12345"
  end
end
