require "../spec_helper"

require "file_utils"

describe Honeybadger::Configuration do
  describe "#configure" do
    it "allows setting and retrieving the api key" do
      new_api_key = "abcdefg"

      protect_configuration do
        Honeybadger.configuration.api_key = new_api_key
        Honeybadger.api_key.should eq new_api_key
      end
    end

    it "has an endpoint configuration" do
      Honeybadger.endpoint.to_s.should eq "https://api.honeybadger.io"

      protect_configuration do
        alternate_endpoint = Path["https://honeybadger.example.com"]
        Honeybadger.configuration.endpoint = alternate_endpoint
        Honeybadger.endpoint.to_s.should eq alternate_endpoint.to_s
      end

      # configure endpoint with string
      protect_configuration do
        alternate_endpoint = "https://honeybadger.example.com"
        Honeybadger.configuration.endpoint = alternate_endpoint
        Honeybadger.endpoint.to_s.should eq alternate_endpoint
      end
    end

    it "populates the revision" do
      Honeybadger.revision.should_not be ""
    end

    it "populates the hostname" do
      Honeybadger.hostname.should_not be ""

      protect_configuration do
        a_hostname = "example_hostname"
        Honeybadger.configuration.hostname = a_hostname
        Honeybadger.hostname.should eq a_hostname
      end
    end

    it "populates the project_root" do
      Honeybadger.project_root.should eq FileUtils.pwd

      protect_configuration do
        path = "/"
        Honeybadger.configuration.project_root = path
        Honeybadger.project_root.should eq path
      end
    end

    describe "report_data" do
      it "allows setting the report_data variable" do
        protect_configuration do
          Honeybadger.configuration.report_data = false
          Honeybadger.report_data?.should be_false
        end
      end

      it "defaults to true" do
        Honeybadger.report_data?.should be_true
      end

      it "overrides development environments" do
        protect_configuration do
          Honeybadger.configure do |config|
            # when the environments "look like production"
            config.development_environments = ["dont_send_data"]
            config.environment = "send_data"

            # but the report data is true
            config.report_data = false
          end

          Honeybadger.report_data?.should be_false
        end

        protect_configuration do
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

    describe "environments" do
      it "defaults development and test to be develpment environments" do
        protect_configuration do
          ["development","test"].each do |tested_env|
            Honeybadger.configuration.environment = tested_env
            Honeybadger.configuration.development?.should be_true
          end
        end
      end

      it "allows overriding the development environments" do
        protect_configuration do
          Honeybadger.configure do |configure|
            configure.development_environments = ["test"]
          end

          Honeybadger.configuration.development_environments.should eq ["test"]
        end
      end

      it "allows setting the development environment" do
        protect_configuration do
          Honeybadger.configure("xxxx", environment: "honeybadger_test")
          Honeybadger.configuration.environment.should eq "honeybadger_test"
        end

        protect_configuration do
          Honeybadger.configure do |config|
            config.environment = "honeybadger_development"
          end

          Honeybadger.configuration.environment.should eq "honeybadger_development"
        end
      end

      it "defaults to not a development environment" do
        Honeybadger.configuration.development?.should be_false
      end
    end

  end
end
