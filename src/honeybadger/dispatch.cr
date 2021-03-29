require "log"

module Honeybadger
  class Dispatch
    Log = ::Log.for("honeybadger")

    def self.send_async(payload : Payload) : Nil
      spawn do
        new(payload).send
      end
    end

    def self.send(payload : Payload) : Nil
      new(payload).send
    end

    def initialize(@payload : Honeybadger::Payload)
    end

    def send : Nil
      return message_for(:disabled) unless Honeybadger.report_data?

      message_for Api.new.send(@payload)
    end

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
