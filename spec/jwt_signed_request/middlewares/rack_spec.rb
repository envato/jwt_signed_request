# frozen_string_literal: true

require 'jwt_signed_request/middlewares/rack'

RSpec.describe JWTSignedRequest::Middlewares::Rack do
  let(:app) { ->(env) { [200, env, "app"] } }
  let(:middleware) { JWTSignedRequest::Middlewares::Rack.new(app, secret_key: 'secret') }
  let(:env) { {} }

  subject(:verify_request) { middleware.call(env) }

  context 'when fails verification' do
    before do
      allow(JWTSignedRequest).to receive(:verify).and_raise(JWTSignedRequest::UnauthorizedRequestError)
    end

    it 'returns an unauthorized status code' do
      code, _header, _body = verify_request
      expect(code).to eq(401)
    end
  end

  context 'when verification is successful' do
    before do
      allow(JWTSignedRequest).to receive(:verify)
    end

    it 'returns a 200 ok status code' do
      code, _header, _body = verify_request
      expect(code).to eq(200)
    end
  end

  context 'with named key store' do
    let(:middleware) { JWTSignedRequest::Middlewares::Rack.new(app, key_store_id: 'my_key_store_id') }

    it 'passes key store ID option' do
      expect(JWTSignedRequest).to receive(:verify) do |args|
        expect(args[:key_store_id]).to eq('my_key_store_id')
      end
      verify_request
    end
  end

  context 'when exclude_paths options is defined' do
    let :middleware do
      JWTSignedRequest::Middlewares::Rack.new(app, secret_key: 'secret', exclude_paths: /api|health/)
    end

    before do
      allow(JWTSignedRequest).to receive(:verify)
    end

    context 'and request path is not excluded' do
      let(:env) { {'PATH_INFO' => '/verify'} }

      it 'verifies the request' do
        verify_request
        expect(JWTSignedRequest).to have_received(:verify)
      end
    end

    context 'and request path is excluded' do
      let(:env) { {'PATH_INFO' => '/health'} }

      it 'does not verify the request' do
        verify_request
        expect(JWTSignedRequest).not_to have_received(:verify)
      end
    end
  end
end
