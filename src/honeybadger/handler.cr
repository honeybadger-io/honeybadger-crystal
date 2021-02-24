require "http/server/handler"

module Honeybadger
  class Handler
    include HTTP::Handler

    def initialize(*, factory : Honeybadger::Payload.class, api_key : String, @enabled = true)
      @dispatch = Honeybadger::Dispatch.new api_key, factory
    end

    def call(context)
      response = call_next context
    rescue exception
      send exception, context
      raise exception
    end

    def send(exception, context)
      return unless @enabled
      @dispatch.async_send exception, context
    end
  end
end
