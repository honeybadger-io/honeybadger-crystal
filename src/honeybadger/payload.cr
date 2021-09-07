require "log/json"

module Honeybadger
  # A Payload is a json renderable object which conforms to the honeybadger
  # json schema for [exceptions](https://docs.honeybadger.io/api/exceptions.html)
  #
  # This payload provides a baseline for general use and is intended
  # to be extended by framework or application specific uses to fill in details.
  class Payload
    # The exception to be rendered.
    getter exception : Exception

    # The context object from the current fiber at time of initialization.
    @fiber_context : Context

    # Subclasses of Payload must set @exception, but will likely need to
    # take additional parameters.
    def initialize(@exception : Exception)
      @fiber_context = Context.current.dup
      @explicit_context = Context.new
    end

    # A basic request object contains just a context object.
    # Override this to embed actual request details.
    def request_json(builder)
      builder.field "request" do
        builder.object do
          builder.field "context" do
            context_json(builder)
          end
        end
      end
    end

    # Renders request context provided by http middleware.
    def context_json(builder)
      if Honeybadger.configuration.merge_log_context
        @fiber_context.merge(Log.context.metadata)
      end

      if explicit_context_ = @explicit_context
        @fiber_context.merge explicit_context_
      end

      @fiber_context.to_json(builder)
    end

    # Allows manually appending context
    def set_context(hash_context : Hash) : Nil
      @explicit_context = Context.new(hash_context)
    end

    # Renders the complete json payload.
    def to_json(builder : JSON::Builder)
      builder.object do
        notifier_json builder
        request_json builder
        error_json builder
        server_json builder
      end
    end

    # Renders the metadata "notifier" stanza of the json payload.
    private def notifier_json(builder)
      builder.field "notifier" do
        builder.object do
          builder.field "name", "honeybadger-crystal"
          builder.field "url", "https://github.com/honeybadger-io/honeybadger-crystal"
          builder.field "version", Honeybadger::VERSION
        end
      end
    end

    # Renders the exception into the json "error" stanza.
    private def error_json(builder)
      builder.field "error" do
        builder.object do
          builder.field "class", exception.class.to_s
          builder.field "message", exception.message
          backtrace_json(builder)
        end
      end
    end

    # Renders the exception backtrace into the "error" stanza.
    private def backtrace_json(builder)
      if exception.backtrace?
        builder.field "backtrace" do
          builder.array do
            exception.backtrace.each do |frame|
              builder.object do
                encode_trace_frame builder, frame
              end
            end
          end
        end
      end
    end

    STACK_FRAME = /^
      (?<path>[^:]+)          # filename
      :(?<line>[\d]+)         # line number
      :(?<char>[\d]+)         # character offset
      \sin\s                  # fixed seperator
      '(?<method>[^']+)'      # method name
    $/x

    # Parses and renders a single stack frame for the "error" stanza.
    private def encode_trace_frame(builder : JSON::Builder, frame : String)
      if matches = STACK_FRAME.match(frame)
        builder.field "file", matches["path"]
        builder.field "method", matches["method"]
        builder.field "number", matches["line"].to_i
      else
        builder.field "file", frame
        builder.field "method", "**unknown**"
        builder.field "number", 0
      end
    end

    # Renders the "server" metadata stanza.
    private def server_json(builder)
      builder.field "server" do
        builder.object do
          builder.field "project_root", Honeybadger.project_root

          if env = Honeybadger.configuration.environment
            builder.field "environment_name", env
          end

          if hostname = Honeybadger.hostname
            builder.field "hostname", hostname
          end

          if revision = Honeybadger.revision
            builder.field "revision", revision
          end

          builder.field "pid", Process.pid
        end
      end
    end
  end
end
