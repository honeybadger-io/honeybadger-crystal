require "../spec_helper"

private def rendered_and_parsed_payload
  rendered = Honeybadger::ExamplePayload.new.to_json
  JSON.parse(rendered)
end

describe Honeybadger::Payload do
  describe "notifier" do
    it "has the name of the crystal shard" do
      rendered_and_parsed_payload["notifier"]["name"].as_s?.should eq "honeybadger-crystal"
    end

    it "has the repository of the crystal shard" do
      rendered_and_parsed_payload["notifier"]["url"].as_s?.should eq "https://github.com/honeybadger-io/honeybadger-crystal"
    end

    it "has the version of the crystal shard" do
      rendered_and_parsed_payload["notifier"]["version"].as_s?.should eq Honeybadger::VERSION
    end
  end

  describe "error" do
    it "has a backtrace" do
      trace = rendered_and_parsed_payload["error"]["backtrace"].as_a
      frame = trace.first

      frame["file"].as_s?.should eq "spec/support/example_payload.cr"
      frame["method"].as_s?.should eq "generate_exception"
      frame["number"].as_i?.should be_a Int32
    end

    it "has the exception class name" do
      rendered_and_parsed_payload["error"]["class"].as_s?.should eq "Exception"
    end

    it "has the exception message" do
      rendered_and_parsed_payload["error"]["message"].as_s?.should eq "mock exception with backtrace"
    end
  end

  describe "server" do
    it "has the project root" do
      rendered_and_parsed_payload["server"]["project_root"].as_s?.should be_a String
    end

    it "has the hostname" do
      rendered_and_parsed_payload["server"]["hostname"].as_s?.should be_a String
    end

    it "has the git revision" do
      rendered_and_parsed_payload["server"]["revision"].as_s?.should be_a String
    end

    it "has the pid" do
      rendered_and_parsed_payload["server"]["pid"].as_i?.should be_a Int32
    end

    it "has the environment" do
      rendered_and_parsed_payload["server"]["environment_name"].as_s?.should eq Honeybadger.configuration.environment
    end
  end
end
