require 'jwt'
require 'jwt_signed_request/claims'
require 'jwt_signed_request/headers'

module JWTSignedRequest
  DEFAULT_ALGORITHM = 'ES256'.freeze
  EMPTY_BODY = "".freeze

  UnauthorizedRequestError = Class.new(StandardError)
  MissingAuthorizationHeaderError = Class.new(UnauthorizedRequestError)
  JWTDecodeError = Class.new(UnauthorizedRequestError)
  RequestVerificationFailedError = Class.new(UnauthorizedRequestError)

  def self.sign(method:, path:, body: EMPTY_BODY, headers:, secret_key:, algorithm: DEFAULT_ALGORITHM, key_id: nil, issuer: nil, additional_headers_to_sign: Claims::EMPTY_HEADERS)
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

  def self.verify(request:, secret_key:, algorithm: nil)
    jwt_token = Headers.fetch('Authorization', request)
    algorithm ||= DEFAULT_ALGORITHM

    if jwt_token.nil?
      raise MissingAuthorizationHeaderError, "Missing Authorization header in the request"
    end

    begin
      claims = JWT.decode(jwt_token, secret_key, algorithm)[0]
      unless verified_request?(request: request, claims: claims)
        raise RequestVerificationFailedError, "Request failed verification"
      end

    rescue ::JWT::DecodeError => e
      raise JWTDecodeError, e.message
    end
  end

  def self.verified_request?(request:, claims:)
    claims['method'].downcase == request.request_method.downcase &&
      claims['path'] == request.fullpath &&
      claims['body_sha'] == Digest::SHA256.hexdigest(request.body.read || "") &&
      verified_headers?(request: request, claims: claims)
  end

  private_class_method :verified_request?

  def self.verified_headers?(request:, claims:)
    parsed_headers = JSON.parse(claims['headers'])

    parsed_headers.all? do |header_key, header_value|
      Headers.fetch(header_key, request) == header_value
    end
  end

  private_class_method :verified_headers?
end
