module Honeybadger
  class ExamplePayload < Payload
    def initialize(@exception : Exception)
    end
  end
end
