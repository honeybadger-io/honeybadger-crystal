require "./honeybadger/*"

module Honeybadger
  VERSION = "0.1.0"

  @@api_key = ""
  @@report_data = true

  # Set the API key to be used for calls to the honeybadger API.
  # Call `configure` during application pre-boot:
  #
  # ```
  #   honeybadger_api_key = ENV["HONEYBADGER_API_KEY"]? || "00000000"
  #   honeybadger_enabled = true
  #
  #   Honeybadger.configure(api_key: honeybadger_api_key)
  # ```
  def self.configure(api_key : String, report_data = true) : Nil
    @@api_key = api_key
    @@report_data = report_data
  end

  # :nodoc:
  def self.api_key
    @@api_key
  end

  def self.report_data? : Bool
    @@report_data
  end

  def self.notify(exception : Exception) : Nil
    Dispatch.send_async Payload.new(exception)
  end
end
