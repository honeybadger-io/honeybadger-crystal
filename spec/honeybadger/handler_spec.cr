require "../spec_helper"
require "log/spec"

Error = Exception.new("Test error")

describe Honeybadger::Handler do
  describe "#call" do
    it "raises the correct exception" do
      handler = Honeybadger::Handler.new
      handler.next = ->(c : HTTP::Server::Context) { raise Error }

      expect_raises(Exception, "Test error") do
        handler.call(MockHttp.new.context)
      end
    end
  end
end
