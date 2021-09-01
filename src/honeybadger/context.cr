module Honeybadger
  def self.context(**args) : Nil
    Context.current.store(args)
  end

  def self.clear() : Nil
    Context.current.clear
  end

  class Context
    def initialize
      @data = Hash(String, String).new
    end

    delegate to_s, to: @data
    forward_missing_to @data

    def self.current : self
      Fiber.current.honeybadger_context
    end

    private def set(key, value)
      self[key.to_s] = value.to_s
    end

    def store(data : NamedTuple)
      data.each do |key, value|
        set(key, value)
      end
    end

    def merge(log_metadata : Log::Metadata)
      log_metadata.each do |key, value|
        set(key, value)
      end
    end
  end
end
