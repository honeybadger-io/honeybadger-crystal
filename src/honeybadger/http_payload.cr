require "json"
require "http"

require "./payload"

module Honeybadger
  # An HttpPayload renders request metadata in addition to the Exception data
  # provided by `Payload`, and should be used for errors which happen during an
  # HTTP::Server request cycle.
  class HttpPayload < Payload
    # :inherit:
    getter exception

    # The request in which the exception was triggered.
    getter request : HTTP::Request

    # :nodoc:
    getter context

    def initialize(@exception : Exception, @context : HTTP::Server::Context)
      @request = @context.request
    end

    # Renders the "request" stanza of the json payload.
    def request_json(builder)
      builder.field "request" do
        builder.object do
          builder.field "url", request.path
          builder.field "params" do
            builder.object do
              request_params builder
            end
          end
        end
      end
    end

    # Renders request parameters by dispatching based on request type.
    private def request_params(builder)
      case
      when multipart_request?
        multipart_params
      when json_request?
        json_params
      else
        form_params
      end.each do |key, value|
        builder.field key, value
      end
    end

    # Renders request parameters sent via http form encoding
    private def form_params : Hash(String, String)
      HTTP::Params.parse(request_body).to_h
    end

    # Renders request parameters sent via http multipart encoding
    private def multipart_params : Hash(String, String)
      params = {} of String => String

      HTTP::FormData.parse(context.request) do |part|
        params[part.name] = part.body.gets_to_end
      end

      params
    end

    # Helper for retrieving parameters from json encoded requests
    private def request_body : String
      if body = request.body
        body.gets_to_end
      else
        "{}"
      end
    end

    # Helper for retrieving parameters from json encoded requests
    private def json_params
      JSON.parse(request_body).as_h
    end

    # :nodoc:
    private def content_type
      request.headers["content-type"]?
    end

    # Determines if the request looks json encoded
    private def json_request? : Bool
      return false unless header = content_type
      header.matches? %r|application/json|
    end

    # Determines if the request looks multipart encoded
    private def multipart_request? : Bool
      return false unless header = content_type
      header.matches? %r|^multipart/form-data|
    end
  end
end
