# frozen_string_literal: true

require 'jwt_signed_request'

RSpec.describe JWTSignedRequest::Sign do
  let(:method) { 'POST' }
  let(:path) { '/api/endpoint' }
  let(:headers) { {'content-type' => 'application/json'} }
  let(:body) { 'data' }
  let(:private_key) do
    <<-PEM.gsub(/^\s+/, "")
      -----BEGIN EC PRIVATE KEY-----
      MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
      AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
      3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
      -----END EC PRIVATE KEY-----
    PEM
  end

  let(:secret_key) { OpenSSL::PKey::EC.new(private_key) }
  let(:claims) { {secret: 'password'} }

  before do
    allow(JWTSignedRequest::Claims).to receive(:generate).and_return(claims)
    allow(JWT).to receive(:encode)
  end

  context 'with explicit algorithm' do
    let(:algorithm) { 'HS256' }

    subject(:signed_request) do
      described_class.call(
        method: method,
        path: path,
        headers: headers,
        body: body,
        algorithm: algorithm,
        secret_key: secret_key,
        key_id: 'my-key-id',
      )
    end

    it 'generates a claim using the request' do
      signed_request

      expect(JWTSignedRequest::Claims).to have_received(:generate).with(
        method: method,
        path: path,
        headers: headers,
        body: body,
        additional_headers_to_sign: nil,
        issuer: nil,
      )
    end

    it 'signs the claims using the secret key and algorithm' do
      signed_request

      expect(JWT).to have_received(:encode).with(
        claims,
        secret_key,
        algorithm,
        kid: 'my-key-id',
      )
    end
  end

  context 'with omitted algorithm' do
    subject(:signed_request) do
      described_class.call(
        method: method,
        path: path,
        headers: headers,
        body: body,
        secret_key: secret_key,
      )
    end

    it 'uses the ES256 algorithm by default' do
      signed_request

      expect(JWT).to have_received(:encode).with(claims, secret_key, 'ES256', {})
    end
  end

  context 'when signing with additional headers' do
    let(:additional_headers_to_sign) { %w[X-AUTH] }

    subject(:signed_request) do
      described_class.call(
        method: method,
        path: path,
        headers: headers,
        body: body,
        secret_key: secret_key,
        additional_headers_to_sign: additional_headers_to_sign,
      )
    end

    it 'signs the claims with the additional headers' do
      signed_request

      expect(JWTSignedRequest::Claims).to have_received(:generate).with(
        method: method,
        path: path,
        headers: headers,
        body: body,
        additional_headers_to_sign: additional_headers_to_sign,
        issuer: nil,
      )
    end
  end

  it 'generates a claim using the request including an issuer' do
    described_class.call(
      method: method,
      path: path,
      headers: headers,
      body: body,
      secret_key: secret_key,
      key_id: 'my-key-id',
      issuer: 'the-issuer',
    )

    expect(JWTSignedRequest::Claims).to have_received(:generate).with(
      method: method,
      path: path,
      headers: headers,
      body: body,
      additional_headers_to_sign: nil,
      issuer: 'the-issuer',
    )
  end

  context 'when configured with default key store' do
    before do
      JWTSignedRequest.configure_keys do |config|
        config.add_signing_key(
          key_id: 'my-key-id',
          key: secret_key,
          algorithm: 'ES256',
        )
      end
    end

    subject(:sign_request) do
      described_class.call(
        method: method,
        path: path,
        headers: headers,
        body: body,
        key_id: 'my-key-id',
      )
    end

    it 'can sign requests without passing secret_key and algorithm', :aggregate_failures do
      expect(JWTSignedRequest::Claims).to receive(:generate).with(
        method: method,
        path: path,
        headers: headers,
        body: body,
        additional_headers_to_sign: nil,
        issuer: nil,
      )
      expect(JWT).to receive(:encode).with(
        claims,
        secret_key,
        'ES256',
        { kid: 'my-key-id' },
      )

      sign_request
    end
  end

  context 'when configured with named key store' do
    before do
      JWTSignedRequest.configure_keys('named-key-store') do |config|
        config.add_signing_key(
          key_id: 'my-key-id',
          key: secret_key,
          algorithm: 'ES256',
        )
      end
    end

    subject(:sign_request) do
      described_class.call(
        method: method,
        path: path,
        headers: headers,
        body: body,
        key_id: 'my-key-id',
        key_store_id: 'named-key-store',
      )
    end

    it 'can sign requests without passing secret_key and algorithm', :aggregate_failures do
      expect(JWTSignedRequest::Claims).to receive(:generate).with(
        method: method,
        path: path,
        headers: headers,
        body: body,
        additional_headers_to_sign: nil,
        issuer: nil,
      )
      expect(JWT).to receive(:encode).with(
        claims,
        secret_key,
        'ES256',
        { kid: 'my-key-id' },
      )

      sign_request
    end
  end
end
