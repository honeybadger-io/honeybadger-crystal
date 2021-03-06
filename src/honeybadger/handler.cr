require "http/server/handler"

module Honeybadger
  class Handler
    include HTTP::Handler

    def initialize(*, factory : Honeybadger::Payload.class, enabled = true)
      @dispatch = Honeybadger::Dispatch.new factory, enabled
    end

    def call(context)
      response = call_next context
    rescue exception
      @dispatch.async_send exception, context
      raise exception
    end
  end
end
