module Honeybadger
  class Api
    BASE_URL = Path["https://api.honeybadger.io"]

    private getter payload, api_key

    def initialize(@payload : Payload)
    end

    def request_headers
      HTTP::Headers{
        "Content-Type" => "application/json",
        "X-API-Key" => Honeybadger.api_key,
        "User-Agent" => "Crystal #{Crystal::VERSION}; #{Honeybadger::VERSION}",
      }
    end

    def send
      Response.new request("v1/notices", payload.to_json)
    end

    private def request(path : String, message_body : String)
      endpoint = BASE_URL.join path
      HTTP::Client.post endpoint.to_s, request_headers, body: message_body
    end
  end
end
