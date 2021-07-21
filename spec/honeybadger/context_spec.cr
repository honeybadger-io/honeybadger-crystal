require "../spec_helper"
require "uuid"

describe "Honeybadger.notify with context" do
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
end
