require 'rack'
require 'jwt_signed_request'

module JWTSignedRequest
  module Middlewares
    class Rack
      UNAUTHORIZED_STATUS_CODE = 401

      def initialize(app, options = {})
        @app = app
        @secret_key = options[:secret_key]
        @algorithm = options[:algorithm]
        @exclude_paths = options[:exclude_paths]
      end

      def call(env)
        begin
          unless excluded_path?(env)
            args = {
              request: ::Rack::Request.new(env),
              secret_key: secret_key,
              algorithm: algorithm
            }.reject { |_, value| value.nil? }

            ::JWTSignedRequest.verify(**args)
          end

          app.call(env)
        rescue ::JWTSignedRequest::UnauthorizedRequestError => e
          [UNAUTHORIZED_STATUS_CODE, {'Content-Type' => 'application/json'} , []]
        end
      end

      private

      attr_reader :app, :secret_key, :algorithm, :exclude_paths

      def excluded_path?(env)
        !exclude_paths.nil? &&
          env['PATH_INFO'].match(exclude_paths)
      end
    end
  end
end
