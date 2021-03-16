module Honeybadger
  class ExamplePayload < Payload
    def initialize(@exception : Exception = self.class.generate_exception)
    end

    def self.generate_exception
      raise "mock exception with backtrace"
    rescue e
      return e
    end

    def environment_name
      "testing environment"
    end
  end
end
