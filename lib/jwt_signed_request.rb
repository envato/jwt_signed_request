require 'jwt'
require 'jwt_signed_request/claims'
require 'jwt_signed_request/verify'

module JWTSignedRequest
  DEFAULT_ALGORITHM = 'ES256'.freeze
  EMPTY_BODY = "".freeze

  UnauthorizedRequestError = Class.new(StandardError)
  MissingAuthorizationHeaderError = Class.new(UnauthorizedRequestError)
  JWTDecodeError = Class.new(UnauthorizedRequestError)
  RequestVerificationFailedError = Class.new(UnauthorizedRequestError)

  def self.sign(method:, path:,
                body: EMPTY_BODY, headers:,
                secret_key:, algorithm: DEFAULT_ALGORITHM,
                key_id: nil, issuer: nil,
                additional_headers_to_sign: Claims::EMPTY_HEADERS)
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

  def self.verify(*args)
    Verify.call(*args)
  end
end
