require "json"
require "http"

require "./payload"

module Honeybadger
  class HttpPayload < Payload
    Log = ::Log.for("honeybadger")

    getter exception, request, context

    @request : HTTP::Request

    def initialize(@exception : Exception, @context : HTTP::Server::Context)
      @request = @context.request
    end

    def has_request?
      true
    end

    private def encode_request(builder)
      builder.field "url", request.path
      builder.field "params" do
        builder.object do
          request_params builder
        end
      end
    end

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

    private def form_params : Hash(String, String)
      HTTP::Params.parse(request_body).to_h
    end

    private def multipart_params : Hash(String, String)
      params = {} of String => String

      HTTP::FormData.parse(context.request) do |part|
        params[part.name] = part.body.gets_to_end
      end

      params
    end

    private def request_body : String
      if body = request.body
        body.gets_to_end
      else
        ""
      end
    end

    private def json_params
      JSON.parse(request_body).as_h
    end

    private def content_type
      request.headers["content-type"]?
    end

    private def json_request? : Bool
      return false unless header = content_type
      header.matches? %r|application/json|
    end

    private def multipart_request? : Bool
      return false unless header = content_type
      header.matches? %r|^multipart/form-data|
    end
  end
end
