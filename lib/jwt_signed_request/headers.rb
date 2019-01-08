# frozen_string_literal: true

# We need a way to pull out the headers from a RAW Rack ENV hash.
#
# We took out the bits we need to lookup the headers from:
# https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/http/headers.rb
#
# We didn't want to include actionpack as a dependency of the library as it brings in alot of
# other dependencies.

module JWTSignedRequest
  class Headers
    def self.fetch(key, request)
      new(request).fetch(key)
    end

    def initialize(request)
      @request = request
    end

    def fetch(key)
      env_key = env_name(key)
      request_env[env_key]
    end

    private

    attr_reader :request

    def request_env
      request.env
    end

    CGI_VARIABLES = Set.new(%W[
      AUTH_TYPE
      CONTENT_LENGTH
      CONTENT_TYPE
      GATEWAY_INTERFACE
      HTTPS
      PATH_INFO
      PATH_TRANSLATED
      QUERY_STRING
      REMOTE_ADDR
      REMOTE_HOST
      REMOTE_IDENT
      REMOTE_USER
      REQUEST_METHOD
      SCRIPT_NAME
      SERVER_NAME
      SERVER_PORT
      SERVER_PROTOCOL
      SERVER_SOFTWARE
    ]).freeze

    private_constant :CGI_VARIABLES

    HTTP_HEADER = /\A[A-Za-z0-9-]+\z/

    private_constant :HTTP_HEADER

    def env_name(key)
      key = key.to_s
      if key =~ HTTP_HEADER
        key = key.upcase.tr('-', '_')
        key = "HTTP_" + key unless CGI_VARIABLES.include?(key)
      end
      key
    end
  end
end
