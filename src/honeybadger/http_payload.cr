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
    getter http_request : HTTP::Request

    def initialize(@exception : Exception, @http_request : HTTP::Request)
      super(@exception)
    end

    # Renders the "request" stanza of the json payload.
    def request_json(builder)
      builder.field "request" do
        builder.object do
          builder.field "url", http_request.path
          builder.field "params" do
            request_params builder
          end

          builder.field "context" do
            context_json builder
          end
        end
      end
    end

    # Renders request parameters by dispatching based on request type.
    private def request_params(builder)
      builder.object do
        case
        when multipart_request?
          multipart_params
        when json_request?
          json_params
        else
          form_params
        end.each do |key, value|
          if Honeybadger.configuration.filter_keys.includes? key
            builder.field key, "[FILTERED]"
          else
            builder.field key, value
          end
        end
      end
    end

    # Renders request parameters sent via http form encoding
    private def form_params : Hash(String, String)
      HTTP::Params.parse(request_body).to_h
    end

    # Renders request parameters sent via http multipart encoding
    private def multipart_params : Hash(String, String)
      params = {} of String => String

      HTTP::FormData.parse(http_request) do |part|
        params[part.name] = part.body.gets_to_end
      end

      params
    end

    # Helper for retrieving parameters from json encoded requests
    private def request_body : String
      if body = http_request.body
        body.gets_to_end
      else
        "{}"
      end
    end

    # Helper for retrieving parameters from json encoded requests
    private def json_params : Hash(String, String)
      JSON.parse(request_body).as_h.transform_values(&.to_s)
    end

    # :nodoc:
    private def content_type
      http_request.headers["content-type"]?
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
