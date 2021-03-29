module Honeybadger
  # A response from the Honeybadger API
  class Response
    @success : Bool

    def initialize(@response : HTTP::Client::Response)
      @success = (200..299).includes? @response.status_code
    end

    def success? : Bool
      @success
    end

    # Retrieves the Honeybadger event ID from the response payload.
    def parsed_id : String?
      decoded = Hash(String, String).from_json body
      decoded["id"]?
    rescue JSON::ParseException
      nil
    end

    delegate body, status, status_code, to: @response
  end
end
