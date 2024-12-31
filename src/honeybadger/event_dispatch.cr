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

      # Main run loop
      # 1. Buffer messages until either 60 seconds have passed or the buffer
      #    exceeds 5MB
      # 2. Flush the buffer to the Honeybadger API
      # 3. Clear the buffer
      loop do
        buffering = true
        wait_time = 60.seconds

        while buffering
          # If the previous iteration exceeded the buffer cap, we flushed it and
          # now we need to place it into the fresh buffer
          if next_event
            @buffer.puts next_event
            next_event = nil
          end

          started_waiting = Time.monotonic
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

            wait_time -= Time.monotonic - started_waiting
          when timeout(wait_time)
            buffering = false
            next_event = nil
          end
        end

        unless @buffer.empty?
          # This must be computed outside of the spawned fiber so that we don't
          # clear it in the ensure block below before it's been sent.
          payload = @buffer.to_s
          spawn send payload
        end
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
