# frozen_string_literal: true

module JWTSignedRequest
  class KeyStore
    def initialize
      @signing_keys = {}
      @verification_keys = {}
    end

    def add_signing_key(key_id:, key:, algorithm:)
      @signing_keys.store(key_id,
        {
          key: key,
          algorithm: algorithm
        })
    end

    def add_verification_key(key_id:, key:, algorithm:)
      @verification_keys.store(key_id,
        {
          key: key,
          algorithm: algorithm
        })
    end

    def get_signing_key(key_id:)
      @signing_keys.fetch(key_id, {})
    end

    def get_verification_key(key_id:)
      @verification_keys.fetch(key_id, {})
    end
  end
end
