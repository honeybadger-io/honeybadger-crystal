require "log"

module Honeybadger
  # Dispatch is responsible for:
  # - Sending payloads to the API, optionally asynchronously
  # - Parsing response codes
  # - Emitting developer friendly status messages
  class Dispatch
    Log = ::Log.for("honeybadger")

    # Sends a payload in a non-blocking way.
    def self.send_async(payload : Payload) : Nil
      spawn do
        new(payload).send
      end
    end

    # Sends a payload to the reporting api.
    def self.send(payload : Payload) : Nil
      new(payload).send
    end

    # :nodoc:
    def initialize(@payload : Honeybadger::Payload)
    end

    # :nodoc:
    def send : Nil
      if Honeybadger.report_data?
        message_for Api.new.send(@payload.to_json)
      else
        # render the payload anyway, so the codepath is still executed in development mode
        @payload.to_json
        message_for(:disabled)
      end
    end

    # Logs a human friendly response message for standard api response codes.
    def message_for(response : Response)
      Log.info do
        case response.status
        when HTTP::Status::CREATED # 201
          if notice_id = response.parsed_id
            "Success ⚡ https://app.honeybadger.io/notice/#{notice_id} #{response.status_code}"
          else
            "Success ⚡ #{response.status_code}"
          end
        when HTTP::Status::PAYMENT_REQUIRED # 402
          "Error report failed: payment is required."
        when HTTP::Status::FORBIDDEN # 403
          "Error report failed: API key is invalid."
        when HTTP::Status::TOO_MANY_REQUESTS, HTTP::Status::SERVICE_UNAVAILABLE # 429, 503
          "Error report failed: project is sending too many errors."
        else
          "Error report failed: unknown response from server. (#{response.status_code})"
        end
      end
    end

    # :ditto:
    def message_for(key : Symbol)
      Log.info do
        case key
        when :disabled
          "Success ⚡ Development mode is enabled; this error will be reported if it occurs after you deploy your app."
        end
      end
    end
  end
end
