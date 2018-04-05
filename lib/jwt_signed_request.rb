require 'jwt'
require 'jwt_signed_request/key_store'
require 'jwt_signed_request/sign'
require 'jwt_signed_request/verify'
require 'jwt_signed_request/errors'

module JWTSignedRequest
  extend self

  DEFAULT_ALGORITHM = 'ES256'.freeze
  EMPTY_BODY = "".freeze

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
