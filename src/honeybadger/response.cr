module Honeybadger
  class Response
    @success : Bool

    def initialize(@response : HTTP::Client::Response)
      @success = (200..299).includes? @response.status_code
    end

    def success? : Bool
      @success
    end

    def parsed_id : String?
      decoded = Hash(String, String).from_json body
      decoded["id"]?
    end

    delegate body, status, status_code, to: @response
  end
end
