require "http/server/handler"

module Honeybadger
  class Handler
    include HTTP::Handler

    def initialize(*, @factory : Honeybadger::Payload.class, @api_key : String, @enabled = true)
    end

    def call(context)
      response = call_next context
    rescue exception
      send exception, context
      raise exception
    end

    def send(exception, context)
      return unless @enabled

      puts "Honeybadger Caught #{exception}"
      payload = @factory.new(exception, context)
      puts payload.to_json
      # Honeybadger::Dispatch.new(@api_key).send(payload)
      puts "Honeybadger finished sending it for archival"
    end
  end
end
