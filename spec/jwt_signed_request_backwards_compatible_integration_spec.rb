ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'jwt_signed_request/middlewares/rack'
require 'jwt_signed_request'

RSpec.describe "Integration test" do
  include Rack::Test::Methods

  let(:algorithm) { 'ES256' }

  def app
    public_key = <<-pem.gsub(/^\s+/, "")
      -----BEGIN PUBLIC KEY-----
      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/O
      exDdlmXEjHYaixzYIduluGXd3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
      -----END PUBLIC KEY-----
    pem

    Rack::Builder.new do
      use JWTSignedRequest::Middlewares::Rack,
        secret_key: OpenSSL::PKey::EC.new(public_key),
        algorithm: 'ES256'

      map "/" do
        run Proc.new {|env| [200, {'Content-Type' => 'application/json'}, []] }
      end
    end
  end

  context 'when request is unsigned' do
    it 'receives an unauthorized status code' do
      get '/'
      expect(last_response.status).to eq(401)
    end
  end

  context 'when request is signed with a different private key' do
    let(:private_key) do
      <<-pem.gsub(/^\s+/, "")
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIO4uHlYp5qN6bMJTpwrkXVZkLNMLDrgay5wJGJvE/dCwoAoGCCqGSM49
        AwEHoUQDQgAEUUDX/9UmvQH1312oPBVjrmF0DzfCcLVVsGFAmyPgHiQuM+lj/I4w
        hPUBUQdavy12vg6VqMra1Hps7acm5ZcZ0A==
        -----END EC PRIVATE KEY-----
      pem
    end

    it 'receives an unauthorized status code' do
      jwt_token = JWTSignedRequest.sign(
        method: 'GET',
        path: '/',
        body: '',
        headers: {'Content-Type' => 'application/json'},
        secret_key: OpenSSL::PKey::EC.new(private_key),
        algorithm: 'ES256'
      )

      get '/', '', { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
      expect(last_response.status).to eq(401)
    end
  end

  context 'when request is signed with the correct private key' do
    let(:private_key) do
      <<-pem.gsub(/^\s+/, "")
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
        AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
        3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
        -----END EC PRIVATE KEY-----
      pem
    end

    it 'request is signed and verified successfully' do
      body = {"first_name" => "Bob", "last_name" => "Hawke"}

      jwt_token = JWTSignedRequest.sign(
        method: 'POST',
        path: '/',
        body: body,
        headers: {'Content-Type' => 'application/json'},
        secret_key: OpenSSL::PKey::EC.new(private_key),
        algorithm: 'ES256'
      )

      post '/', body, { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
      expect(last_response.status).to eq(200)
    end

    context 'with query parameters in the path' do
      it 'request is signed and verified successfully' do
        jwt_token = JWTSignedRequest.sign(
          method: 'GET',
          path: '/?foo=bar&baz=quz',
          body: '',
          headers: {'Content-Type' => 'application/json'},
          secret_key: OpenSSL::PKey::EC.new(private_key),
          algorithm: 'ES256'
        )

        get '/?foo=bar&baz=quz', nil, { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
        expect(last_response.status).to eq(200)
      end
    end
  end
end
