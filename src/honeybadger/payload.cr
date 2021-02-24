module Honeybadger
  abstract class Payload
    abstract def to_json

    private def notifier_json(builder)
      builder.field "name", "Honeybadger Crystal"
      builder.field "url", "https://github.com/honeybadger-io/honeybadger-crystal"
      builder.field "version", Honeybadger::VERSION
    end

    private def encode_exception(builder)
      builder.field "class", exception.class.to_s
      builder.field "message", exception.message
      builder.field "fingerprint", "fingerprint"

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

  end
end
