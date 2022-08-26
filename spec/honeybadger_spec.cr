require "./spec_helper"

require "yaml"
require "uuid"

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

    # This is essentially a compile-time test because there are no easy testing
    # paradigms to validate that a fiber was spawned.
    it "allows specifying the behavior to be synchronous" do
      Honeybadger.notify Honeybadger::ExamplePayload.generate_exception, synchronous: true
    end

    it "allows specifying a context hash with stringable data types" do
      exception = Honeybadger::ExamplePayload.generate_exception

      example_contexts = [
        { "user_id" => UUID.random },
        { "user_id" => 23 },
        { 23 => 45 },
        { "user_age" => 3.14 },
        { "user_is_nil" => nil }
      ]

      example_contexts.each do |context_hash|
        Honeybadger.notify(exception, context: context_hash)
      end
    end

    it "allows sending a notification with a string" do
      Honeybadger.notify "notification reason", context: { "user_id" => 23 }
      Honeybadger.notify "notification reason", error_class: "AnError"
      Honeybadger.notify "notification reason", synchronous: true
    end
  end
end
