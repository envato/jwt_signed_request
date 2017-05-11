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
      secret_key:,
      algorithm: DEFAULT_ALGORITHM,
      key_id: nil,
      issuer: nil,
      additional_headers_to_sign: Claims::EMPTY_HEADERS
    )
      @method = method
      @path = path
      @body = body
      @headers = headers
      @secret_key = secret_key
      @algorithm = algorithm
      @key_id = key_id
      @issuer = issuer
      @additional_headers_to_sign = additional_headers_to_sign
    end

    def call
      additional_jwt_headers = key_id ? {kid: key_id} : {}
      JWT.encode(
        Claims.generate(
          method: method,
          path: path,
          headers: headers,
          body: body,
          additional_headers_to_sign: additional_headers_to_sign,
          issuer: issuer
        ),
        secret_key,
        algorithm,
        additional_jwt_headers
      )
    end

    attr_reader \
      :method, :path, :body, :headers, :secret_key, :algorithm,
      :key_id, :issuer, :additional_headers_to_sign
  end
end
