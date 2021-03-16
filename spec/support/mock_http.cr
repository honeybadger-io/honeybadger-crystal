require "uri/params"
require "http"

class MockHttp
  def initialize
  end

  def self.build_multipart_request(*, method = "GET", resource = "/", headers = HTTP::Headers.new, params = {} of String => String)
    io = IO::Memory.new

    HTTP::FormData.build(io) do |builder|
      params.each do |key, value|
        builder.field key.to_s, value
      end

      headers["Content-Type"] = builder.content_type
    end

    io.rewind
    body = io.gets_to_end
    build_request(method: method, resource: resource, headers: headers, body: body)
  end

  def self.build_form_request(*, method = "GET", resource = "/", headers = HTTP::Headers.new, params = {} of String => String)
    body = HTTP::Params.encode(params)
    build_request(method: method, resource: resource, headers: headers, body: body)
  end

  def self.build_json_request(*, method = "GET", resource = "/", headers = HTTP::Headers.new, params = {} of String => String)
    body = params.to_json

    headers["Content-Type"] = "application/json"
    build_request(method: method, resource: resource, headers: headers, body: body)
  end

  def self.build_request(*, method = "GET", resource = "/", headers = HTTP::Headers.new, body = nil)
    body = "" if body.nil?

    HTTP::Request.new method, resource, headers, body
  end

  def self.build_response
    HTTP::Server::Response.new IO::Memory.new, "HTTP/1.1"
  end

  def context(*, request = self.class.build_request, response = self.class.build_response)
    HTTP::Server::Context.new request, response
  end

  def self.with_request(**args)
    new.context request: build_request(**args)
  end
end

