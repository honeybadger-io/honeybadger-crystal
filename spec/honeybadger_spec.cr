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

  describe "#configure with a block" do
    it "yields an instance of Configuration" do
      Honeybadger.configure do |settings|
        settings.should be_a Honeybadger::Configuration
      end
    end
  end

  describe "#configure without a block" do
    protect_configuration do
      Honeybadger.configure("000000", environment: "development")
      Honeybadger.configuration.environment.should eq "development"
    end

    protect_configuration do
      new_api_key = "12345"
      Honeybadger.configure api_key: new_api_key
      Honeybadger.api_key.should eq new_api_key
    end
  end

  describe "#notify" do
    it "allows manually dispatching an erorr" do
      exception = Honeybadger::ExamplePayload.generate_exception
      Honeybadger.notify(exception)
    end

    it "allows specifying the context" do
      exception = Honeybadger::ExamplePayload.generate_exception
      Honeybadger.notify(exception, example_context)
      Honeybadger.notify(exception, context: example_context)
    end
  end
end
