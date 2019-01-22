# frozen_string_literal: true

require 'jwt_signed_request/middlewares/faraday'
require 'securerandom'

RSpec.describe JWTSignedRequest::Middlewares::Faraday do
  let(:options) do
    {
      secret_key: 'secret'
    }
  end

  let(:env) do
    {
      method: 'POST',
      url: double(:request_uri => '/api/endpoint?offset=1&limit=10'),
      body: "body",
      request_headers: {
        'Content-Type' => 'application/json'
      }
    }
  end

  let(:jwt_token) { SecureRandom.hex }

  let(:middleware) {
    described_class.new(lambda { |env|
      Faraday::Response.new(env)
    }, options)
  }

  before do
    allow(JWTSignedRequest).to receive(:sign).and_return(jwt_token)
  end

  describe '#call' do
    it 'sets the jwt token in the Authorization Header' do
      response = middleware.call(env).env
      expect(response[:request_headers]).to include('Authorization' => "Bearer #{jwt_token}")
    end

    context 'with optional settings' do
      let(:options) do
        {
          secret_key: 'secret',
          key_id: 'my-key-id',
          issuer: 'my-issuer'
        }
      end

      it 'signs the request using the additional settings' do
        middleware.call(env).env
        expect(JWTSignedRequest).to have_received(:sign).with(
          hash_including(key_id: 'my-key-id', issuer: 'my-issuer')
        )
      end
    end
  end
end
