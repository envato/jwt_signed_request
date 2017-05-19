require 'jwt'
require 'jwt_signed_request/sign'
require 'jwt_signed_request/verify'

module JWTSignedRequest
  DEFAULT_ALGORITHM = 'ES256'.freeze
  EMPTY_BODY = "".freeze

  UnauthorizedRequestError = Class.new(StandardError)
  MissingAuthorizationHeaderError = Class.new(UnauthorizedRequestError)
  JWTDecodeError = Class.new(UnauthorizedRequestError)
  RequestVerificationFailedError = Class.new(UnauthorizedRequestError)

  def self.sign(*args)
    Sign.call(*args)
  end

  def self.verify(*args)
    Verify.call(*args)
  end
end
