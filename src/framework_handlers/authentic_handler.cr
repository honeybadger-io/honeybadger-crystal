require "http/server/handler"

# The `Honeybadger::AuthenticHandler` is meant to integrate with the [Lucky web framework](https://luckyframework.org).
#
# It will attempt to fetch a user's ID from the current session, and include it in the error context if available.
module Honeybadger
  class AuthenticHandler
    include HTTP::Handler

    def initialize(*, @factory : Honeybadger::HttpPayload.class = Honeybadger::HttpPayload, @session_key : String = Authentic::ActionHelpers::SIGN_IN_KEY)
    end

    def call(context : HTTP::Server::Context)
      if user_id = context.session.get? @session_key
        Honeybadger.context user_id: user_id
      end

      call_next context
    rescue exception
      payload = @factory.new exception, context.request

      Honeybadger::Dispatch.send_async payload

      raise exception
    end
  end
end
