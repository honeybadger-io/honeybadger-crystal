require "log"

module Honeybadger
  class Dispatch
    def initialize(@api_key : String, @factory : Honeybadger::Payload.class)
    end

    def send(payload : Honeybadger::Payload)
      context = {} of String => String
      api = Api.new(@api_key, payload)
      api.send
    end

    def send(exception : Exception, context : HTTP::Server::Context)
      puts "Honeybadger Caught #{exception}"
      send(@factory.new exception, context)
      puts "Honeybadger finished sending it for archival"
    end

    def async_send(exception : Exception, context : HTTP::Server::Context)
      spawn do
        send exception, context
      end
    end
  end
end
