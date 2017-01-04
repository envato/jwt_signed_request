require 'rack'
require 'jwt_signed_request'

module JWTSignedRequest
  module Middlewares
    class Rack
      UNAUTHORIZED_STATUS_CODE = 401

      def initialize(app, options = {})
        @app = app
        @secret_key = options.fetch(:secret_key)
        @algorithm = options[:algorithm]
      end

      def call(env)
        begin
          ::JWTSignedRequest.verify(
            request: ::Rack::Request.new(env),
            secret_key: secret_key,
            algorithm: algorithm
          )

          app.call(env)
        rescue ::JWTSignedRequest::UnauthorizedRequestError => e
          [UNAUTHORIZED_STATUS_CODE, {'Content-Type' => 'application/json'} , []]
        end
      end

      private

      attr_reader :app, :secret_key, :algorithm
    end
  end
end
