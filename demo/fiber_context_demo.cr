require "http/server"
require "../src/honeybadger"

# A worthy http application server
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

# Configure honeybadger
honeybadger_api_key = ENV["HONEYBADGER_API_KEY"]? || "00000000"
Honeybadger.configure do |config|
  config.api_key = honeybadger_api_key
  config.report_data = false
end

# Routes and actions for the server
router = Router.new
router.on("/raise") do
  # path specific context
  Honeybadger.context(user_id: 23)
  Honeybadger.context(yolo: "always")
  raise "Broken (with local context)!"
end

router.on("/nothing") do
  raise "Broken!"
end

server = HTTP::Server.new([
  HTTP::LogHandler.new(Log.for("http.server")),
  HTTP::ErrorHandler.new,
  Honeybadger::Handler.new,
  router
]) do |http_context|
  http_context.response.content_type = "text/html"
  http_context.response.status = HTTP::Status::NOT_FOUND
  http_context.response.print "<strong>Not found.</strong>"
end

address = server.bind_tcp 8080
puts "Listening on http://#{address}"
server.listen
