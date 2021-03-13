require "../spec_helper"
require "file_utils"

class MockHttp
  def initialize
  end

  def self.build_request(*, method = "GET", resource = "/", headers = nil, body = "")
    HTTP::Request.new method, resource, headers, body
  end

  def self.build_response
    HTTP::Server::Response.new IO::Memory.new, "HTTP/1.1"
  end

  def context(*, request = self.class.build_request, response = self.class.build_response)
    HTTP::Server::Context.new request, response
  end

  def self.with_request(**args)
    new.context request: build_request(**args)
  end
end

describe Honeybadger::HttpPayload do
  describe "compile time data collection" do
    it "populates the compile_dir" do
      Honeybadger::HttpPayload::COMPILE_DIR.should eq FileUtils.pwd
    end

    it "populates the hostname" do
      Honeybadger::HttpPayload::HOSTNAME.should_not be ""
    end

    it "populates the git_revision" do
      Honeybadger::HttpPayload::GIT_REVISION.should_not be ""
    end
  end

  describe "to_json" do
    it "embeds the request path" do
      expected_request_path = "/honeybadger/crystal"

      context = MockHttp.with_request(resource: expected_request_path)
      payload = Honeybadger::HttpPayload.new(Exception.new, context)
      JSON.parse(payload.to_json)["request"]["url"].as_s.should eq expected_request_path
    end
  end
end
