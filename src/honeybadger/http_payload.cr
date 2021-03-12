require "json"
require "http"

require "./payload"

module Honeybadger
  class HttpPayload < Payload
    getter exception, request, context

    @request : HTTP::Request

    COMPILE_DIR  = {{ run("../run_macros/pwd.cr").stringify }}.strip
    GIT_REVISION = {{ run("../run_macros/git_revision.cr").stringify }}.strip
    HOSTNAME     = System.hostname

    def initialize(@exception : Exception, @context : HTTP::Server::Context)
      @request = @context.request
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

        builder.field "request" do
          builder.object do
            encode_request builder
          end
        end

        builder.field "server" do
          builder.object do
            server_details builder
          end
        end
      end
    end

    private def encode_request(builder)
      builder.field "component", "component"
      builder.field "action", "action"
      builder.field "url", request.path
      builder.field "params" do
        builder.object do
          request_params(builder)
        end
      end
    end

    private def request_params(builder)
      builder.field "method", "post"
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

    private def environment_name : Nil
    end
  end
end
