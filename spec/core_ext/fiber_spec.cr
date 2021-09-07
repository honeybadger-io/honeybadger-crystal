require "../spec_helper"

describe Fiber do
  it "is empowered with a `honeybadger_context` method" do
    # compile time test
    Fiber.current.honeybadger_context
  end
end
