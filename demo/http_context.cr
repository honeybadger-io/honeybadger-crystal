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

class MyHoneybadgerNotifier < Honeybadger::Handler
  def context : Honeybadger::ContextHash
    Honeybadger::ContextHash.new.tap do |c|
      c["user_id"] = user_id
    end
  end

  def user_id
    23
  end
end

router = Router.new
router.on("/raise") do
  raise "Broken!"
end

honeybadger_api_key = ENV["HONEYBADGER_API_KEY"]? || "00000000"

Honeybadger.configure(api_key: honeybadger_api_key)

server = HTTP::Server.new([
  HTTP::LogHandler.new(Log.for("http.server")),
  HTTP::ErrorHandler.new,
  MyHoneybadgerNotifier.new,
  router
]) do |http_context|
  http_context.response.content_type = "text/html"
  http_context.response.status = HTTP::Status::NOT_FOUND
  http_context.response.print "<strong>Not found.</strong>"
end

address = server.bind_tcp 8080
puts "Listening on http://#{address}"
server.listen
