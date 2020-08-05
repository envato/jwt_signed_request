# frozen_string_literal: true

require 'faraday'
require 'jwt_signed_request'

module JWTSignedRequest
  module Middlewares
    class Faraday < Faraday::Middleware
      def initialize(app, bearer_schema: nil, **options)
        @bearer_schema = bearer_schema
        @options = options
        super(app)
      end

      def call(env)
        env[:body] ||= ::JWTSignedRequest::EMPTY_BODY

        @jwt_token = ::JWTSignedRequest.sign(
          method:     env[:method],
          path:       env[:url].request_uri,
          headers:    env[:request_headers],
          body:       env[:body],
          **options,
        )

        env[:request_headers].store("Authorization", authorization_header)

        app.call(env)
      end

      private

      attr_reader :app, :env, :bearer_schema, :options, :jwt_token

      def authorization_header
        bearer_schema? ? "Bearer #{jwt_token}" : jwt_token
      end

      def bearer_schema?
        bearer_schema == true
      end
    end
  end
end
