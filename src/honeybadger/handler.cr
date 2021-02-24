require "http/server/handler"

module Honeybadger
  class Handler
    include HTTP::Handler

    def initialize(*, factory : Honeybadger::Payload.class, api_key : String, enabled = true)
      @dispatch = Honeybadger::Dispatch.new api_key, factory, enabled
    end

    def call(context)
      response = call_next context
    rescue exception
      @dispatch.async_send exception, context
      raise exception
    end
  end
end
