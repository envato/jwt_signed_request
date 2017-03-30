require 'jwt_signed_request/claims'
require 'timecop'

RSpec.describe JWTSignedRequest::Claims do
  let(:method) { 'post' }
  let(:path) { '/api/end_point' }
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'secret'
    }
  end

  let(:body) { "user_uuid=abc" }

  let(:additional_headers_to_sign) { ['Authorization'] }

  describe '.generate' do
    let(:issuer) { nil }

    subject(:claims) do
      described_class.generate(
        method: method,
        path: path,
        headers: headers,
        body: body,
        additional_headers_to_sign: additional_headers_to_sign,
        issuer: issuer,
      )
    end

    it 'includes the request method' do
      expect(claims).to include(method: 'post')
    end

    it 'includes the request path' do
      expect(claims).to include(path: '/api/end_point')
    end

    it 'includes a sha of the request body' do
      body = "user_uuid=abc"
      body_sha = Digest::SHA256.hexdigest(body)

      expect(claims).to include(body_sha: body_sha)
    end

    it 'JSON encodes the request headers' do
      def valid_json?(json)
        begin
          JSON.parse(json)
          return true
        rescue JSON::ParserError => e
          return false
        end
      end

      headers = claims[:headers]

      expect(valid_json?(headers)).to eq(true)
    end

    it 'does not include an expiration time claim' do
      request_time = Time.parse("2016-06-02T13:20:30Z")
      Timecop.freeze(request_time) do
        expect(claims.keys).to_not include(:exp)
      end
    end

    it 'omits the issuer' do
      expect(claims.keys).not_to include(:iss)
    end

    context 'when an issuer is supplied' do
      let(:issuer) { 'my-issuer' }

      it 'includes the issuer' do
        expect(claims).to include(iss: 'my-issuer')
      end
    end

    context 'when no more additional_headers_to_sign is defined' do
      subject(:claims) do
        described_class.generate(
          method: method,
          path: path,
          headers: headers,
          body: body,
          issuer: nil
        )
      end

      it 'just signs with the base valid headers' do
        expect(claims).to include(headers: "{\"Content-Type\":\"application/json\"}")
      end
    end

    context 'when a list of additional headers to sign is passed in' do
      let(:additional_headers_to_sign) { ['Authorization'] }

      it 'uses the list of valid headers' do
        expect(claims).to include(headers: "{\"Content-Type\":\"application/json\",\"Authorization\":\"secret\"}")
      end
    end
  end
end
