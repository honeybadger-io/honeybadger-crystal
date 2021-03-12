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
  end
end
