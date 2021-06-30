module Honeybadger
  class ExamplePayload < Payload
    def initialize(@exception : Exception = self.class.generate_exception)
      super(@exception)
    end

    # Generates an exception with a backtrace for testing.
    def self.generate_exception
      raise "mock exception with backtrace"
    rescue e
      return e
    end
  end
end
