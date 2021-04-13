require "./honeybadger/*"

module Honeybadger
  VERSION = "0.1.0"

  class Configuration
    # A Honeybadger API key.
    property api_key = ""

    # The API endpoint for sending Honeybadger payloads.
    property endpoint : Path = Path["https://api.honeybadger.io"]

    # The project git revision. Evaluated at compile time.
    getter revision : String = {{ run("./run_macros/git_revision.cr").stringify }}.strip

    # The system or container hostname.
    property hostname : String = System.hostname

    # The path to the projects source code. Evaluated at compile time.
    property project_root : String = {{ run("./run_macros/pwd.cr").stringify }}.strip

    # Send data to the Honeybadger collector
    property report_data = true

    def endpoint=(path : String) : String
      @endpoint = Path[path]
      path
    end
  end

  # The Honeybadger Configuration singleton instance.
  class_getter configuration = Configuration.new

  # Set the API key to be used for calls to the honeybadger API.
  # Call `configure` during an application boot sequence and populate the api key:
  #
  # ```
  #   honeybadger_api_key = ENV["HONEYBADGER_API_KEY"]? || "00000000"
  #   Honeybadger.configure(api_key: honeybadger_api_key)
  # ```
  def self.configure(api_key : String, *, report_data = true) : Nil
    configure do |s|
      s.api_key = api_key
      s.report_data = report_data
    end
  end

  # Configure Honeybadger with a block.
  #
  # ```
  # Honeybadger.configure do |settings|
  #   settings.api_key = "00000"
  #   settings.project_root = "/path/to/project"
  # end
  # ```
  def self.configure(&block) : Nil
    yield configuration
  end

  {% for method in [:api_key, :endpoint, :project_root, :revision, :hostname]%}
    # Alias of `Configuration.{{ method.id }}`.
    def self.{{ method.id }}
      configuration.{{ method.id }}
    end
  {% end %}

  # Alias of `Configuration.report_data`
  def self.report_data? : Bool
    configuration.report_data
  end

  def self.notify(exception : Exception) : Nil
    Dispatch.send_async Payload.new(exception)
  end
end
