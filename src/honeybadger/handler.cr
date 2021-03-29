require "http/server/handler"

module Honeybadger
  class Handler
    include HTTP::Handler

    def initialize(@factory : Honeybadger::HttpPayload.class = Honeybadger::HttpPayload)
    end

    def call(context)
      response = call_next context
    rescue exception
      Honeybadger::Dispatch.send_async(@factory.new(exception, context))
      raise exception
    end
  end
end
