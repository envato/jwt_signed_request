require 'digest'
require 'json'
require 'rack/utils'

module JWTSignedRequest
  class Claims
    EMPTY_HEADERS = [].freeze

    def self.generate(args)
      new(**args).generate
    end

    def initialize(method:, path:, headers:, body:, additional_headers_to_sign: EMPTY_HEADERS, timeout: DEFAULT_TIMEOUT, issuer:)
      @method = method
      @path = path
      @headers = headers
      @body = body
      @additional_headers_to_sign = additional_headers_to_sign
      @timeout = timeout
      @issuer = issuer
      @include_exp = false # TODO: allow this to be configured
    end

    private_class_method :new

    def generate
      result = {
        method: method,
        path: path,
        headers: serialized_headers,
        body_sha: body_sha,
      }
      result[:exp] = (Time.now + timeout).to_i if @include_exp
      result[:iss] = issuer if issuer
      result
    end

    private

    attr_reader :method, :path, :headers, :body, :additional_headers_to_sign, :timeout, :issuer

    HEADERS_TO_SIGN = %w(
      Content-Type
      Content-Length
      Date
      User-Agent
    ).freeze

    private_constant :HEADERS_TO_SIGN

    DEFAULT_TIMEOUT = 30.freeze

    private_constant :DEFAULT_TIMEOUT

    def formatted_body
      case body
        when String
          body
        when Array, Hash
          Rack::Utils.build_query(body)
      end
    end

    def body_sha
      Digest::SHA256.hexdigest(formatted_body)
    end

    def headers_to_sign
      HEADERS_TO_SIGN + additional_headers_to_sign
    end

    def filtered_headers
      headers.select do |header_name, _|
        headers_to_sign.include?(header_name)
      end
    end

    def serialized_headers
      JSON.dump(filtered_headers)
    end
  end
end
