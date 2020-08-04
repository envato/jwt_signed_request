# frozen_string_literal: true

require 'rack'
require 'jwt_signed_request'

module JWTSignedRequest
  module Middlewares
    class Rack
      UNAUTHORIZED_STATUS_CODE = 401

      def initialize(app, secret_key: nil, algorithm: nil, leeway: nil, exclude_paths: nil)
        @app = app
        @secret_key = secret_key
        @algorithm = algorithm
        @leeway = leeway
        @exclude_paths = exclude_paths
      end

      def call(env)
        ::JWTSignedRequest.verify(**verification_args(env)) unless excluded_path?(env)
        app.call(env)
      rescue ::JWTSignedRequest::UnauthorizedRequestError
        [UNAUTHORIZED_STATUS_CODE, {'Content-Type' => 'application/json'}, []]
      end

      private

      attr_reader :app, :secret_key, :algorithm, :leeway, :exclude_paths

      def excluded_path?(env)
        !exclude_paths.nil? &&
          env['PATH_INFO'].match(exclude_paths)
      end

      def verification_args(env)
        {
          request: ::Rack::Request.new(env),
          secret_key: secret_key,
          algorithm: algorithm,
          leeway: leeway,
        }
      end
    end
  end
end
