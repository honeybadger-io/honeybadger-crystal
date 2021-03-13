require "json"
require "http"

require "./payload"

module Honeybadger
  class HttpPayload < Payload
    getter exception, request, context

    @request : HTTP::Request

    def initialize(@exception : Exception, @context : HTTP::Server::Context)
      @request = @context.request
    end

    def has_request?
      true
    end

    private def encode_request(builder)
      builder.field "component", "component"
      builder.field "action", "action"
      builder.field "url", request.path
      builder.field "params" do
        builder.object do
          request_params(builder)
        end
      end
    end

    private def request_params(builder)
      builder.field "method", "post"
    end
  end
end
