# The `Honeybadger::AuthenticHandler` is meant to integrate with the [Lucky web framework](https://luckyframework.org).
#
# It will attempt to fetch a user's ID from the current session, and include it in the error context if available.
class Honeybadger::AuthenticHandler
  include HTTP::Handler

  def initialize(@factory : Honeybadger::HttpPayload.class = Honeybadger::HttpPayload)
  end

  def call(context : HTTP::Server::Context)
    if (user_id = context.session.get?(Authentic::ActionHelpers::SIGN_IN_KEY))
      Honeybadger.context(user_id: user_id)
    end

    call_next(context)
  rescue exception
    payload = @factory.new(exception, context.request)

    Honeybadger::Dispatch.send_async(payload)

    raise exception
  end
end
