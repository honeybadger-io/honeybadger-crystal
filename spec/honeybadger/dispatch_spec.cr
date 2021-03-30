require "../spec_helper"
require "log/spec"

private def dispatch
  Honeybadger::Dispatch.new(Honeybadger::ExamplePayload.new)
end

private def dispatch_message_for_status(status)
  response = Honeybadger::Response.new(
    MockHttp.client_response(status_code: status)
  )

  Log.capture do |logs|
    dispatch.message_for(response)
  end
end

describe Honeybadger::Dispatch do
  describe "message_for" do
    it "logs disabled message for development mode" do
      Log.capture do
        dispatch.message_for(:disabled)
      end.check :info, /Development mode is enabled/
    end

    it "logs successful messages with response id" do
      mock_json = {id: "1234abcd"}

      response = Honeybadger::Response.new(
        MockHttp.client_response(status_code: HTTP::Status::CREATED, body: mock_json.to_json)
      )

      Log.capture do
        dispatch.message_for(response)
      end.check :info, /app\.honeybadger\.io\/notice\/#{mock_json[:id]}/
    end

    it "logs successful messages without response id" do
      dispatch_message_for_status(HTTP::Status::CREATED)
        .check :info, /Success ⚡ 201/
    end

    it "logs 402 with readable message" do
      dispatch_message_for_status(HTTP::Status::PAYMENT_REQUIRED)
        .check :info, /payment is required/
    end

    it "logs 403 with readable message" do
      dispatch_message_for_status(HTTP::Status::FORBIDDEN)
        .check :info, /API key is invalid/
    end

    it "logs 429/503 with readable message" do
      dispatch_message_for_status(HTTP::Status::TOO_MANY_REQUESTS)
        .check :info, /project is sending too many errors/

      dispatch_message_for_status(HTTP::Status::SERVICE_UNAVAILABLE)
        .check :info, /project is sending too many errors/
    end

    it "logs other with readable message" do
      dispatch_message_for_status(HTTP::Status::OK)
        .check :info, /unknown response from server. \(200\)/
    end
  end
end
