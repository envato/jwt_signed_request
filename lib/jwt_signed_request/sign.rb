# frozen_string_literal: true

require 'jwt_signed_request/claims'

module JWTSignedRequest
  class Sign
    def self.call(*args)
      new(*args).call
    end

    def initialize(
      method:,
      path:,
      body: EMPTY_BODY,
      headers:,
      secret_key: nil,
      algorithm: nil,
      key_id: nil,
      lookup_key_id: key_id,
      issuer: nil,
      subject: nil,
      additional_headers_to_sign: nil
    )
      @method = method
      @path = path
      @body = body
      @headers = headers
      @secret_key = secret_key
      @algorithm = algorithm
      @key_id = key_id
      @lookup_key_id = lookup_key_id
      @issuer = issuer
      @subject = subject
      @additional_headers_to_sign = additional_headers_to_sign
    end

    def call
      JWT.encode(claims, secret_key, algorithm, additional_jwt_headers)
    end

    private

    attr_reader \
      :method, :path, :body, :headers,
      :key_id, :lookup_key_id, :issuer, :subject, :additional_headers_to_sign

    def stored_key
      @stored_key ||= JWTSignedRequest.key_store.get_signing_key(key_id: lookup_key_id)
    end

    def secret_key
      @secret_key ||= stored_key.fetch(:key) { raise MissingKeyIdError }
    end

    def algorithm
      @algorithm ||= stored_key.fetch(:algorithm, DEFAULT_ALGORITHM)
    end

    def additional_jwt_headers
      key_id ? {kid: key_id} : {}
    end

    def claims
      Claims.generate(
        method: method,
        path: path,
        headers: headers,
        body: body,
        additional_headers_to_sign: additional_headers_to_sign,
        issuer: issuer,
        subject: subject
      )
    end
  end
end
