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

  def self.verify(request:, secret_key:, algorithm: nil, leeway: nil)
    # TODO: algorithm is deprecated and will be removed in future
    verify = true
    options = {}
    if leeway
      # TODO: Once JWT v2.0.0 has been released, we should upgrade to it and start using `exp_leeway` instead
      #  'leeway' will still work, but 'exp_leeway' is more explicit and is the documented way to do it.
      #  see https://github.com/jwt/ruby-jwt/pull/187
      options[:leeway] = leeway.to_i
    end
    jwt_token = Headers.fetch('Authorization', request)

    if jwt_token.nil?
      raise MissingAuthorizationHeaderError, "Missing Authorization header in the request"
    end

    begin
      claims = JWT.decode(jwt_token, secret_key, verify, options)[0]
      unless verified_request?(request: request, claims: claims)
        raise RequestVerificationFailedError, "Request failed verification"
      end

    rescue ::JWT::DecodeError => e
      raise JWTDecodeError, e.message
    end
  end

  def self.verified_request?(request:, claims:)
    claims['method'].to_s.downcase == request.request_method.downcase &&
      claims['path'] == request.fullpath &&
      claims['body_sha'] == Digest::SHA256.hexdigest(request_body(request: request)) &&
      verified_headers?(request: request, claims: claims)
  end

  private_class_method :verified_request?

  def self.request_body(request:)
    string = request.body.read
    request.body.rewind
    string
  end

  private_class_method :request_body

  def self.verified_headers?(request:, claims:)
    parsed_headers = begin
      JSON.parse(claims['headers'].to_s)
    rescue JSON::ParserError
      {}
    end

    parsed_headers.all? do |header_key, header_value|
      Headers.fetch(header_key, request) == header_value
    end
  end

  private_class_method :verified_headers?
end
