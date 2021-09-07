require "../spec_helper"

require "file_utils"

describe Honeybadger::Configuration do
  around_each do |test|
    protect_configuration do
      protect_env do
        test.run
      end
    end
  end

  describe "api_key" do
    it "has a blank default value" do
      Honeybadger.api_key.should eq ""
    end

    it "can be read from an environment variable" do
      test_api_key = "2468"
      ENV["HONEYBADGER_API_KEY"] = test_api_key
      Honeybadger::Configuration.new.api_key.should eq test_api_key
    end

    it "allows setting and retrieving the api key" do
      new_api_key = "abcdefg"

      Honeybadger.configuration.api_key = new_api_key
      Honeybadger.api_key.should eq new_api_key
    end
  end

  describe "endpoint" do
    it "has a default value" do
      Honeybadger.endpoint.to_s.should eq "https://api.honeybadger.io"
    end

    it "can be configured with a Path" do
      alternate_endpoint = Path["https://honeybadger.example.com"]
      Honeybadger.configuration.endpoint = alternate_endpoint
      Honeybadger.endpoint.to_s.should eq alternate_endpoint.to_s
    end

    it "can be configured with a string" do
      alternate_endpoint = "https://honeybadger.example.com"
      Honeybadger.configuration.endpoint = alternate_endpoint
      Honeybadger.endpoint.to_s.should eq alternate_endpoint
    end

    it "can be configured with an environment variable" do
      test_value = "2468"
      ENV["HONEYBADGER_ENDPOINT"] = test_value
      Honeybadger::Configuration.new.endpoint.should eq Path[test_value]
    end
  end

  describe "revision" do
    it "populates something to the revision automatically" do
      Honeybadger.revision.should_not be ""
      Honeybadger.revision.should_not be_nil
    end

    it "can be configured with an environment variable" do
      test_value = "2468"
      ENV["HONEYBADGER_REVISION"] = test_value
      Honeybadger::Configuration.new.revision.should eq test_value
    end
  end

  describe "hostname" do
    it "populates the hostname automatically" do
      Honeybadger.hostname.should_not be ""
    end

    it "can be configured" do
      a_hostname = "example_hostname"
      Honeybadger.configuration.hostname = a_hostname
      Honeybadger.hostname.should eq a_hostname
    end

    it "can be configured with an environment variable" do
      test_value = "2468"
      ENV["HONEYBADGER_HOSTNAME"] = test_value
      Honeybadger::Configuration.new.hostname.should eq test_value
    end
  end

  describe "project_root" do
    it "populates the project_root automatically" do
      Honeybadger.project_root.should eq FileUtils.pwd
    end

    it "can be configured" do
      path = "/"
      Honeybadger.configuration.project_root = path
      Honeybadger.project_root.should eq path
    end

    it "can be configured with an environment variable" do
      test_value = "2468"
      ENV["HONEYBADGER_PROJECT_ROOT"] = test_value
      Honeybadger::Configuration.new.project_root.should eq test_value
    end
  end

  describe "report_data" do
    it "defaults to true" do
      Honeybadger.report_data?.should be_true
    end

    it "can be configured" do
      Honeybadger.configuration.report_data = false
      Honeybadger.report_data?.should be_false
    end

    it "can be configured with an environment variable" do
      test_value = "TRUE"
      ENV["HONEYBADGER_REPORT_DATA"] = test_value
      Honeybadger::Configuration.new.report_data.should be_true
    end

    describe "explicit report_data config overrides development_environments configuration" do
      it "works when report_data is false" do
        Honeybadger.configure do |config|
          # when the environments "look like production"
          config.development_environments = ["dont_send_data"]
          config.environment = "send_data"

          # but the report data is false
          config.report_data = false
        end

        Honeybadger.report_data?.should be_false
      end

      it "works when report_data is true" do
        Honeybadger.configure do |config|
          # when the environment "look like development"
          config.development_environments = ["dont_send_data"]
          config.environment = "dont_send_data"

          # but the report data flag is true
          config.report_data = true
        end

        Honeybadger.report_data?.should be_true
      end
    end
  end

  describe "development_environments" do
    it "defaults development and test to be develpment environments" do
      ["development","test"].each do |tested_env|
        Honeybadger.configuration.environment = tested_env
        Honeybadger.configuration.development?.should be_true
      end
    end

    it "can be configured" do
      Honeybadger.configure do |configure|
        configure.development_environments = ["test"]
      end

      Honeybadger.configuration.development_environments.should eq ["test"]
    end

    it "can be configured with an environment variable" do
      test_value = "fizz, buzz"
      ENV["HONEYBADGER_DEVELOPMENT_ENVIRONMENTS"] = test_value
      Honeybadger::Configuration.new.development_environments.should eq ["fizz", "buzz"]
    end

    it "defaults to not a development environment" do
      Honeybadger.configuration.development?.should be_false
    end
  end

  describe "environment name" do
    it "defaults to a nil environment name" do
      Honeybadger.configuration.environment.should be_nil
    end

    it "can be configured with shorthand" do
      Honeybadger.configure("xxxx", environment: "honeybadger_test")
      Honeybadger.configuration.environment.should eq "honeybadger_test"
    end

    it "can be configured in block syntax" do
      Honeybadger.configure do |config|
        config.environment = "honeybadger_development"
      end

      Honeybadger.configuration.environment.should eq "honeybadger_development"
    end

    it "can be configured with an environment variable" do
      test_value = "2468"
      ENV["HONEYBADGER_ENVIRONMENT"] = test_value
      Honeybadger::Configuration.new.environment.should eq test_value
    end
  end

  describe "merge_log_context" do
    it "defaults to true" do
      Honeybadger::Configuration.new.merge_log_context.should be_true
    end

    it "can be configured with block syntax" do
      Honeybadger.configure do |config|
        config.merge_log_context = false
      end

      Honeybadger.configuration.merge_log_context.should be_false
    end
  end
end
