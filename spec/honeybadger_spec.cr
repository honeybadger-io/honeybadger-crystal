require "./spec_helper"
require "yaml"

describe Honeybadger do
  describe "Version" do
    it "has a version number which is in sync with the shard file" do
      shard_yaml = File.open("shard.yml") do |file|
        Honeybadger::VERSION.should eq YAML.parse(file)["version"].as_s
      end
    end
  end

  describe "#configure" do
    it "allows setting and retrieving the api key" do
      old_api_key = Honeybadger.api_key
      new_api_key = "12345"

      Honeybadger.configure api_key: new_api_key
      Honeybadger.api_key.should eq new_api_key

      Honeybadger.configure api_key: old_api_key
    end
  end
end
