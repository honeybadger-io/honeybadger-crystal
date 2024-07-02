require "./event"

module Honeybadger
  class EventDispatch
    # Allow for a spike of events
    @channel = Channel(Event).new(1 << 16)
    @buffer = IO::Memory.new

    getter? running = false

    def send(event : Event)
      ensure_running

      select
      when @channel.send event
      else # if the buffer is full, we just skip
      end
    end

    private def ensure_running
      sync { start }
    end

    private def start
      return if running?

      @running = true
      spawn run

      at_exit do
        # Give the consumer fiber a chance to buffer any further events
        Fiber.yield
        send @buffer.to_s
      end
    end

    private def run
      next_event = nil

      loop do
        buffering = true

        while buffering
          # If the previous iteration exceeded the buffer cap, we flushed it and
          # now we need to place it into the fresh buffer
          if next_event
            @buffer.puts next_event
            next_event = nil
          end

          select
          when event = @channel.receive
            # Limits for events endpoint: https://docs.honeybadger.io/api/reporting-events/#limits

            json = event.to_json
            # Max event size is 100KB
            if json.bytesize <= 100 * 1024
              # Maximum payload size is 5MB
              if @buffer.bytesize + json.bytesize < 5 * 1024 * 1024
                @buffer.puts json
                next_event = nil
              else
                next_event = json
                buffering = false
              end
            end
          when timeout(1.second)
            next_event = nil
          end
        end

        # This must be computed outside of the spawned fiber
        payload = @buffer.to_s
        spawn send payload
      ensure
        @buffer.clear
      end
    end

    @mutex = Mutex.new

    def sync
      @mutex.synchronize { yield }
    end

    def send(payload : String) : Nil
      if Honeybadger.report_data?
        Api.new.send(payload, to: "v1/events")
      end
    end
  end
end
