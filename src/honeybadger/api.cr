module Honeybadger
  # An API wrapper for the Honeybadger HTTP API
  class Api
    # :nodoc:
    def initialize
    end

    # :nodoc:
    def request_headers
      HTTP::Headers{
        "Content-Type" => "application/json",
        "X-API-Key" => Honeybadger.api_key,
        "User-Agent" => "Crystal #{Crystal::VERSION}; #{Honeybadger::VERSION}",
      }
    end

    # Sends a payload to the exception reporting api endpoint.
    def send(payload)
      Response.new request("v1/notices", payload)
    end

    # :nodoc:
    private def request(path : String, message_body : String)
      endpoint = Honeybadger.endpoint.join path
      HTTP::Client.post endpoint.to_s, request_headers, body: message_body
    end
  end
end
