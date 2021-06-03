require "http/server/handler"

module Honeybadger
  # An HTTP Server Handler which intercepts unhandled exceptions and sends
  # them to the Honeybadger exception reporting api.
  class Handler
    include HTTP::Handler

    # Builds a new handler for inclusion into an HTTP server config.
    # The default reporting payload renders general http context information.
    # Framework or application specific should be provided by subclassing
    # `HttpPayload` and providing an explicit factory.
    def initialize(@factory : Honeybadger::HttpPayload.class = Honeybadger::HttpPayload)
    end

    # :nodoc:
    def call(http_context)
      response = call_next http_context
    rescue exception
      payload = @factory.new(exception, http_context.request)
      payload.set_context(context)

      Honeybadger::Dispatch.send_async(payload)

      raise exception
    end

    # Extend to provide helpful data about the context of this request.
    def context : Honeybadger::ContextHash
      Honeybadger::ContextHash.new
    end
  end
end
