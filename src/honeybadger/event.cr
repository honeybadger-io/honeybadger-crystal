require "json"
require "uri"

module Honeybadger
  struct Event
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "ts", converter: Honeybadger::Event::RFC3339Converter)]
    getter timestamp : Time

    def self.new(**properties)
      new Time.utc, properties
    end

    def self.new(properties : Hash)
      new Time.utc, properties
    end

    def initialize(@timestamp, properties = NamedTuple.new)
      properties.each do |key, value|
        self[key.to_s] = value
      end
    end

    def []=(key : String, value)
      json_unmapped[key] = coerce(value)
    end

    delegate :[], :[]?, to: json_unmapped

    def merge(other : self) : self
      event = self.class.new(timestamp: timestamp)

      json_unmapped.each { |key, value| event[key] = value }
      other.json_unmapped.each { |key, value| event[key] = value }

      event
    end

    private def coerce(value : JSON::Any)
      value
    end

    private def coerce(value : JSON::Any::Type)
      JSON::Any.new value
    end

    private def coerce(value : Array)
      coerce value.map { |item| coerce item }
    end

    private def coerce(value : Hash)
      coerce value.transform_values { |item| coerce item }
    end

    private def coerce(value : URI)
      coerce value.to_s
    end

    # 8-, 16-, and 32-bit integers have to be a special case because the type
    # checker doesn't know whether to upcast them to Int64 or Float64 for the
    # JSON::Any::Type case.
    private def coerce(value : Int)
      coerce value.to_i64
    end

    private def coerce(value)
      # String#inspect_unquoted escapes unprintable characters
      coerce value.to_s.inspect_unquoted
    end

    module RFC3339Converter
      extend self

      def to_json(timestamp : Time, json : JSON::Builder)
        json.string do |io|
          timestamp.to_rfc3339 fraction_digits: 3, io: io
        end
      end
    end
  end
end
