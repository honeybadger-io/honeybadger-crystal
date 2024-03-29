require "../spec_helper"

private def rendered_and_parsed_payload
  JSON.parse Honeybadger::ExamplePayload.new.to_json
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

    it "has the environment when it's available" do
      protect_configuration do
        Honeybadger.configuration.environment = "honeybadger_tests"
        rendered_and_parsed_payload["server"]["environment_name"].as_s?.should eq Honeybadger.configuration.environment
      end
    end
  end

  describe "request" do
    describe "context" do
      it "merges in log context" do
        Log.context.clear
        Log.context.set user_id: 72

        protect_configuration do
          Honeybadger.configuration.merge_log_context = true
          rendered_and_parsed_payload["request"]["context"]["user_id"].as_s?.should eq "72"
        end

        Log.context.clear
      end

      it "includes the context from the current fiber" do
        Honeybadger::Context.current.clear
        Honeybadger.context(user_id: 46)
        rendered_and_parsed_payload["request"]["context"]["user_id"].as_s?.should eq "46"
        Honeybadger::Context.current.clear
      end

      it "includes explicit context" do
        payload = Honeybadger::ExamplePayload.new
        context = { :user_id => 23 }
        payload.set_context context
        parsed = JSON.parse(payload.to_json)
        parsed["request"]["context"]["user_id"].as_s?.should eq "23"
      end
    end
  end
end
