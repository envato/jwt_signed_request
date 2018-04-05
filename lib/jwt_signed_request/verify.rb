require 'jwt_signed_request/headers'
require 'jwt_signed_request/errors'

module JWTSignedRequest
  class Verify
    def self.call(*args)
      new(*args).call
    end

    # TODO: secret_key & algorithm is deprecated and will be removed in future.
    # For now we will support its functionaility
    def initialize(request:, secret_key: nil, algorithm: nil, leeway: nil)
      @request = request
      @secret_key = secret_key
      @algorithm = algorithm
      @leeway = leeway
    end

    def call
      if jwt_token.nil?
        raise MissingAuthorizationHeaderError, "Missing Authorization header in the request"
      end

      verify_request!
    end

    private

    attr_reader :request, :leeway

    def stored_key
      jwt_header, _, _, _ = ::JWT.decoded_segments(jwt_token, false)
      key_id = jwt_header.fetch('kid') { raise MissingKeyIdError }
      signed_algorithm = jwt_header.fetch('alg')
      JWTSignedRequest.key_store.get_verification_key(key_id: key_id).tap do |key|
        if signed_algorithm != key[:algorithm]
          raise AlgorithmMismatchError
        end
      end
    end

    def secret_key
      @secret_key ||= stored_key.fetch(:key) { raise MissingKeyIdError }
    end

    def jwt_token
      @jwt_token ||= Headers.fetch('Authorization', request)
    end

    def claims
      @claims ||= begin
        verify = true
        options = {}

        if leeway
          # TODO: Once JWT v2.0.0 has been released, we should upgrade to it
          # and start using `exp_leeway` instead 'leeway' will still work, but
          # 'exp_leeway' is more explicit and is the documented way to do it.
          #
          # See https://github.com/jwt/ruby-jwt/pull/187.
          options[:leeway] = leeway.to_i
        end

        JWT.decode(jwt_token, secret_key, verify, options)[0]
      rescue ::JWT::DecodeError => e
        raise JWTDecodeError, e.message
      end
    end

    def verify_request!
      unless request.request_method.casecmp(claims['method'].to_s) == 0
        raise RequestMethodVerificationFailedError, "Request failed method verification"
      end
      unless parsed_claims_uri.path == request.path
        raise RequestPathVerificationFailedError, "Request failed path verification"
      end
      unless verified_query_strings?
        raise RequestQueryVerificationFailedError, "Request failed query string verification"
      end
      unless claims['body_sha'] == Digest::SHA256.hexdigest(request_body)
        raise RequestBodyVerificationFailedError, "Request failed body verification"
      end
      unless verified_headers?
        raise RequestHeaderVerificationFailedError, "Request failed header verification"
      end
    end

    def request_body
      string = request.body.read
      request.body.rewind
      string
    end

    def verified_headers?
      parsed_headers = begin
        JSON.parse(claims['headers'].to_s)
      rescue JSON::ParserError
        {}
      end

      parsed_headers.all? do |header_key, header_value|
        Headers.fetch(header_key, request) == header_value
      end
    end

    def parsed_claims_uri
      @parsed_claims_uri ||= URI.parse(claims['path'])
    end

    def standard_query_values(path)
      URI.decode_www_form(path.query).sort if path && path.query
    end

    def verified_query_strings?
      claims_query_values == request_query_values
    end

    def claims_query_values
      standard_query_values(parsed_claims_uri)
    end

    def request_query_values
      standard_query_values(URI.parse(request.fullpath))
    end
  end
end
