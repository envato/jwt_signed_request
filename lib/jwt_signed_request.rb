# frozen_string_literal: true

require 'jwt'
require 'jwt_signed_request/key_store'
require 'jwt_signed_request/sign'
require 'jwt_signed_request/verify'
require 'jwt_signed_request/errors'

module JWTSignedRequest
  extend self

  DEFAULT_ALGORITHM = 'ES256'
  DEFAULT_KEY_STORE_ID = '__default__'
  EMPTY_BODY = ''
  private_constant :DEFAULT_KEY_STORE_ID

  def configure_keys(key_store_id = DEFAULT_KEY_STORE_ID)
    key_store = key_stores[key_store_id]
    yield(key_store)
  end

  def key_store(id = DEFAULT_KEY_STORE_ID)
    key_stores[id]
  end

  def sign(**args)
    Sign.call(**args)
  end

  def verify(**args)
    Verify.call(**args)
  end

  private

  def key_stores
    @key_stores ||= Hash.new { |result, key| result[key] = KeyStore.new }
  end
end
