# frozen_string_literal: true

require 'faraday'
require 'jwt_signed_request'

module JWTSignedRequest
  module Middlewares
    class Faraday < Faraday::Middleware
      def initialize(app, options)
        @options = options
        super(app)
      end

      def call(env)
        @jwt_token = ::JWTSignedRequest.sign(
          method:     env[:method],
          path:       env[:url].request_uri,
          headers:    env[:request_headers],
          body:       env.fetch(:body, ::JWTSignedRequest::EMPTY_BODY),
          **optional_settings
        )

        env[:request_headers].store("Authorization", authorization_header)

        app.call(env)
      end

      private

      attr_reader :app, :env, :options, :jwt_token

      def authorization_header
        bearer_schema? ? "Bearer #{jwt_token}" : jwt_token
      end

      def bearer_schema?
        options[:bearer_schema] == true
      end

      def optional_settings
        {
          secret_key:                 options[:secret_key],
          algorithm:                  options[:algorithm],
          additional_headers_to_sign: options[:additional_headers_to_sign],
          key_id:                     options[:key_id],
          issuer:                     options[:issuer],
        }.reject { |_, value| value.nil? }
      end
    end
  end
end
