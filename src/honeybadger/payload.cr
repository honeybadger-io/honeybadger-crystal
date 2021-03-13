module Honeybadger
  abstract class Payload
    abstract def to_json

    COMPILE_DIR  = {{ run("../run_macros/pwd.cr").stringify }}.strip
    GIT_REVISION = {{ run("../run_macros/git_revision.cr").stringify }}.strip
    HOSTNAME     = System.hostname


    def initialize(@exception : Exception)
    end

    def has_request?
      false
    end

    def to_json(builder : JSON::Builder)
      builder.object do
        builder.field "notifier" do
          builder.object do
            notifier_json builder
          end
        end

        builder.field "error" do
          builder.object do
            encode_exception builder
          end
        end

        if has_request?
          builder.field "request" do
            builder.object do
              encode_request builder
            end
          end
        end

        builder.field "server" do
          builder.object do
            server_details builder
          end
        end
      end
    end

    private def notifier_json(builder)
      builder.field "name", "Honeybadger Crystal"
      builder.field "url", "https://github.com/honeybadger-io/honeybadger-crystal"
      builder.field "version", Honeybadger::VERSION
    end

    private def encode_exception(builder)
      builder.field "class", exception.class.to_s
      builder.field "message", exception.message
      builder.field "fingerprint", "fingerprint"

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

    private def encode_trace_frame(builder : JSON::Builder, frame : String)
      if matches = STACK_FRAME.match(frame)
        builder.field "file", matches["path"]
        builder.field "method", matches["method"]
        builder.field "number", matches["line"]
      else
        builder.field "file", frame
        builder.field "method", "**unknown**"
        builder.field "number", 0
      end
    end

    private def server_details(builder)
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

    def environment_name
      nil
    end

  end
end
