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

    it "has report_data" do
      Honeybadger.report_data?.should be_true

      protect_configuration do
        Honeybadger.configuration.report_data = false
        Honeybadger.report_data?.should be_false
      end
    end
  end
end
