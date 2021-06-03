require "./honeybadger/*"

module Honeybadger
  VERSION = "0.1.0"

  alias ContextHash = Hash(String, String | Int32)

  class Configuration
    # A Honeybadger API key.
    property api_key = ""

    # The list of environments considered "development"
    property development_environments : Array(String) = ["development", "test"]

    # The API endpoint for sending Honeybadger payloads.
    property endpoint : Path = Path["https://api.honeybadger.io"]

    # The app environment
    property environment : String? = nil

    # The project git revision. Evaluated at compile time.
    property revision : String = {{ run("./run_macros/git_revision.cr").stringify }}.strip

    # The system or container hostname.
    property hostname : String = System.hostname

    # The path to the projects source code. Evaluated at compile time.
    property project_root : String = {{ run("./run_macros/pwd.cr").stringify }}.strip

    # Explicitly override the development environment check.
    # Nil = check for development environment
    # True = always report data
    # False = never report data
    property report_data : Bool? = nil

    def initialize
      set_from_env
    end

    # Reads configuration from honeybadger prefixed environment variables
    def set_from_env
      {% begin %}
      {% simple_vars = [ "api_key", "development_environments", "endpoint", "environment", "revision", "hostname", "project_root", "report_data" ] %}
      {% for var in simple_vars %}
        if %variable = ENV["HONEYBADGER_{{ var.upcase.id }}"]?
          self.{{ var.id }} = %variable
        end
      {% end %}
      {% end %}
    end

    # Configure development environment list with a string.
    #
    # Used to set the value from an environment variable.
    # Input is split on commas and striped of leading/trailing whitespace.
    #
    # ```
    # config.development_environments = "development, testing, staging"
    # config.development_environments # => ["development", "testing", "staging"]
    # ```
    def development_environments=(value : String)
      @development_environments = value.split(",").map(&.strip)
    end

    # Configures API endpoint with a string.
    #
    # Used to set the value from an environment variable.
    #
    # ```
    # config.endpoint = "http://new_api.honeybadger.io"
    # config.endpoint # => Path["http://new_api.honeybadger.io"]
    # ```
    def endpoint=(path : String) : String
      @endpoint = Path[path]
      path
    end

    # Configures report_data with a string.
    def report_data=(value : String) : Bool
      @report_data = value.downcase == "true"
    end

    # Is the current environment considered a development environment?
    def development? : Bool
      if env = environment
        development_environments.includes? environment
      else
        # if the environment is nil, it's never development
        false
      end
    end

    # Should Honeybadger.cr send data to the honeybadger api?
    #
    # When report_data is unset, default to development? logic.
    def report_data? : Bool
      case @report_data
      when nil
        ! development?
      when true
        true
      else
        false
      end
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
  def self.configure(api_key : String, *, environment : String? = nil) : Nil
    configure do |s|
      s.api_key = api_key
      s.environment = environment if environment
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
    configuration.report_data?
  end

  def self.notify(exception : Exception) : Nil
    Dispatch.send_async Payload.new(exception)
  end

  def self.notify(exception : Exception, context : ContextHash) : Nil
    payload = Payload.new(exception)
    payload.set_context(context)
    Dispatch.send_async payload
  end
end
