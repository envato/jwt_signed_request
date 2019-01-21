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
        jwt_token = ::JWTSignedRequest.sign(
          method:     env[:method],
          path:       env[:url].request_uri,
          headers:    env[:request_headers],
          body:       env.fetch(:body, ::JWTSignedRequest::EMPTY_BODY),
          **optional_settings
        )

        env[:request_headers].store("Authorization", "Bearer #{jwt_token}")
        app.call(env)
      end

      private

      attr_reader :app, :env, :options

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
