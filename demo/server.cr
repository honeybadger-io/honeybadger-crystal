require "http/server"
require "../src/honeybadger"

class Router
  include HTTP::Handler

  def initialize
    @matches = {} of String => Proc(String)
  end

  def call(context)
    if route = @matches[context.request.path]?
      context.response.print route.call
    else
      call_next context
    end
  end

  def on(path : String, &block : -> String) : Nil
    @matches[path] = block
  end
end

router = Router.new
router.on("/raise") do
  # Either or both of these will work
  Log.context.set(admin_id: 42)
  Honeybadger.context(user_id: 23)

  raise "Broken!"
end

honeybadger_api_key = ENV["HONEYBADGER_API_KEY"]? || "00000000"

Honeybadger.configure(api_key: honeybadger_api_key)

server = HTTP::Server.new([
  HTTP::LogHandler.new(Log.for("http.server")),
  HTTP::ErrorHandler.new,
  Honeybadger::Handler.new,
  router
]) do |context|
  context.response.content_type = "text/html"
  context.response.status = HTTP::Status::NOT_FOUND
  context.response.print "<strong>Not found.</strong>"
end

address = server.bind_tcp 8080
puts "Listening on http://#{address}"
server.listen
