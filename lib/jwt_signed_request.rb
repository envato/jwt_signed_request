require 'jwt'
require 'jwt_signed_request/key_store'
require 'jwt_signed_request/sign'
require 'jwt_signed_request/verify'

module JWTSignedRequest
  extend self

  DEFAULT_ALGORITHM = 'ES256'.freeze
  EMPTY_BODY = "".freeze

  UnauthorizedRequestError = Class.new(StandardError)
  MissingAuthorizationHeaderError = Class.new(UnauthorizedRequestError)
  JWTDecodeError = Class.new(UnauthorizedRequestError)
  RequestVerificationFailedError = Class.new(UnauthorizedRequestError)
  MissingKeyIdError = Class.new(UnauthorizedRequestError)
  UnknownKeyIdError = Class.new(UnauthorizedRequestError)
  AlgorithmMismatchError = Class.new(UnauthorizedRequestError)

  def configure_keys
    yield(key_store)
  end

  def key_store
    @key_store ||= KeyStore.new
  end

  def sign(*args)
    Sign.call(*args)
  end

  def verify(*args)
    Verify.call(*args)
  end
end
