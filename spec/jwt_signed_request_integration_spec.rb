ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'jwt_signed_request/middlewares/rack'
require 'jwt_signed_request'

RSpec.describe "Integration test" do
  include Rack::Test::Methods

  let(:key_id) { 'client_a' }

  before(:all) do
    private_key = <<-pem.gsub(/^\s+/, "")
      -----BEGIN EC PRIVATE KEY-----
      MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
      AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
      3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
      -----END EC PRIVATE KEY-----
    pem

    public_key = <<-pem.gsub(/^\s+/, "")
      -----BEGIN PUBLIC KEY-----
      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/O
      exDdlmXEjHYaixzYIduluGXd3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
      -----END PUBLIC KEY-----
    pem

    JWTSignedRequest.configure_keys do |config|
      config.add_signing_key(
        key_id: 'client_a',
        key: OpenSSL::PKey::EC.new(private_key),
        algorithm: 'ES256',
      )

      config.add_verification_key(
        key_id: 'client_a',
        key: OpenSSL::PKey::EC.new(public_key),
        algorithm: 'ES256',
      )
    end
  end

  def app
    Rack::Builder.new do
      use JWTSignedRequest::Middlewares::Rack
      map "/" do
        run Proc.new {|env| [200, {'Content-Type' => 'application/json'}, []] }
      end
    end
  end

  context 'when request is unsigned' do
    it 'returns an unauthorized status code' do
      get '/'
      expect(last_response.status).to eq(401)
    end
  end

  context 'when request is signed with an unknown key id' do
    let(:key_id) { 'unknown' }

    it 'returns an unauthorized status code' do
      correct_private_key = <<-pem.gsub(/^\s+/, "")
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
        AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
        3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
        -----END EC PRIVATE KEY-----
      pem

      body = {"first_name" => "Bob", "last_name" => "Hawke"}

      jwt_token = JWTSignedRequest.sign(
        method: 'POST',
        path: '/',
        body: body,
        headers: {'Content-Type' => 'application/json'},
        key_id: key_id,
        secret_key: OpenSSL::PKey::EC.new(correct_private_key),
      )

      post '/', body, { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
      expect(last_response.status).to eq(401)
    end
  end

  context 'when signed with the wrong key' do
    let(:key_id) { 'client_a' }

    it 'returns an unauthorized status code' do
      incorrect_private_key = <<-pem.gsub(/^\s+/, "")
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIO4uHlYp5qN6bMJTpwrkXVZkLNMLDrgay5wJGJvE/dCwoAoGCCqGSM49
        AwEHoUQDQgAEUUDX/9UmvQH1312oPBVjrmF0DzfCcLVVsGFAmyPgHiQuM+lj/I4w
        hPUBUQdavy12vg6VqMra1Hps7acm5ZcZ0A==
        -----END EC PRIVATE KEY-----
      pem

      body = {"first_name" => "Bob", "last_name" => "Hawke"}

      jwt_token = JWTSignedRequest.sign(
        method: 'POST',
        path: '/',
        body: body,
        headers: {'Content-Type' => 'application/json'},
        key_id: key_id,
        secret_key: OpenSSL::PKey::EC.new(incorrect_private_key),
      )

      post '/', body, { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
      expect(last_response.status).to eq(401)
    end
  end

  context 'when signed with an incorrect algorithm' do
    let(:key_id) { 'client_a' }

    it 'returns an unauthorized status code' do
      body = {"first_name" => "Bob", "last_name" => "Hawke"}

      jwt_token = JWTSignedRequest.sign(
        method: 'POST',
        path: '/',
        body: body,
        headers: {'Content-Type' => 'application/json'},
        key_id: key_id,
        secret_key: "secret",
        algorithm: 'HS512'
      )

      post '/', body, { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
      expect(last_response.status).to eq(401)
    end
  end

  context 'when request is signed with the correct key_id' do
    let(:key_id) { 'client_a' }

    it 'request is signed and verified successfully' do
      body = {"first_name" => "Bob", "last_name" => "Hawke"}

      jwt_token = JWTSignedRequest.sign(
        method: 'POST',
        path: '/',
        body: body,
        headers: {'Content-Type' => 'application/json'},
        key_id: key_id,
      )

      post '/', body, { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
      expect(last_response.status).to eq(200)
    end
  end

  context 'with lookup_key_id specified' do
    before do
      private_key = <<-pem.gsub(/^\s+/, "")
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
        AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
        3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
        -----END EC PRIVATE KEY-----
      pem

      JWTSignedRequest.configure_keys do |config|
        config.add_signing_key(
          key_id: 'server_a',
          key: OpenSSL::PKey::EC.new(private_key),
          algorithm: 'ES256',
        )
      end
    end

    it 'request is signed and verified successfully' do
      body = {"first_name" => "Bob", "last_name" => "Hawke"}

      jwt_token = JWTSignedRequest.sign(
        method: 'POST',
        path: '/',
        body: body,
        headers: {'Content-Type' => 'application/json'},
        key_id: 'client_a',
        lookup_key_id: 'server_a',
      )
      sent_key_id = ::JWT.decoded_segments(jwt_token, false).first.fetch('kid')

      post '/', body, { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => jwt_token }
      expect(last_response.status).to eq(200)
      expect(sent_key_id).to eq('client_a')
    end
  end
end
