# frozen_string_literal: true

require 'jwt'
require 'jwt_signed_request/key_store'
require 'jwt_signed_request/sign'
require 'jwt_signed_request/verify'
require 'jwt_signed_request/errors'

module JWTSignedRequest
  extend self

  DEFAULT_ALGORITHM = 'ES256'
  EMPTY_BODY = ''

  def configure_keys(key_store_id = nil)
    yield KeyStore.find(key_store_id)
  end

  def key_store(id = nil)
    KeyStore.find(id)
  end

  def sign(**kwargs)
    Sign.call(**kwargs)
  end

  def verify(**kwargs)
    Verify.call(**kwargs)
  end
end
