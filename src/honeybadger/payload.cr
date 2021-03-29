module Honeybadger
  # A Payload is a json renderable object which conforms to the honeybadger
  # json schema for [exceptions](https://docs.honeybadger.io/api/exceptions.html)
  #
  # This payload provides a baseline for general use and is intended
  # to be extended by framework or application specific uses to fill in details.
  class Payload
    # The path to source code at compile time.
    COMPILE_DIR  = {{ run("../run_macros/pwd.cr").stringify }}.strip

    # The git revision at compile time.
    GIT_REVISION = {{ run("../run_macros/git_revision.cr").stringify }}.strip

    # The system or container hostname.
    HOSTNAME     = System.hostname

    # The exception to be rendered.
    getter exception : Exception

    # Subclasses of Payload must set @exception, but will likely need to
    # take additional parameters for context.
    def initialize(@exception : Exception)
    end

    # Stub implemented to ease the common paradigm of embedding request
    # details into the payload.
    def request_json(builder); end

    # Stub implemented to provide the environment name, e.g. "production"
    def environment_name; end

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
          builder.field "project_root", COMPILE_DIR

          if env = environment_name
            builder.field "environment_name", env
          end

          if hostname = HOSTNAME
            builder.field "hostname", hostname
          end

          if revision = GIT_REVISION
            builder.field "revision", revision
          end

          builder.field "pid", Process.pid
        end
      end
    end

  end
end
