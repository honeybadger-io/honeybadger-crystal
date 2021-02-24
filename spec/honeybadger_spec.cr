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

  it "works" do
    false.should eq(true)
  end
end
