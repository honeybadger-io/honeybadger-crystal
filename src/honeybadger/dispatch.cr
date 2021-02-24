module Honeybadger
  class Dispatch
    def initialize(@api_key : String)
    end

    def send(payload : Honeybadger::Payload)
      context = {} of String => String
      api = Api.new(@api_key, payload)
      api.send
    end
  end
end
