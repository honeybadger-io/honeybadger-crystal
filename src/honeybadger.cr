require "./core_ext/*"
require "./honeybadger/*"

module Honeybadger
  VERSION = "0.2.1"

  alias ContextHash = Hash(String, String)

  # Send notifications to the Honeybadger API
  def self.notify(exception : Exception) : Nil
    Dispatch.send_async Payload.new(exception)
  end

  def self.notify(exception : Exception, context : Hash) : Nil
    payload = Payload.new(exception)
    payload.set_context(context)
    Dispatch.send_async payload
  end
end
