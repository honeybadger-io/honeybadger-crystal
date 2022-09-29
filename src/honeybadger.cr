require "./core_ext/*"
require "./honeybadger/*"

module Honeybadger
  VERSION = "0.2.3"

  alias ContextHash = Hash(String, String)

  # Send notifications to the Honeybadger API
  def self.notify(
    exception : Exception | String,
    context : Hash? = nil,
    *,
    synchronous : Bool = false,
    error_class : String? = nil
  ) : Nil

    payload = case exception
      when Exception
        Payload.new exception
      when String
        Payload.new exception, error_class: error_class
      else
        raise ArgumentError.new("Invalid exception class, expected a String or Exception")
      end

    if context
      payload.set_context context
    end

    Dispatch.send payload, synchronous: synchronous
  end
end
