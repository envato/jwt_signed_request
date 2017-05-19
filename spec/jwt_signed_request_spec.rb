require 'jwt_signed_request'

RSpec.describe JWTSignedRequest do
  describe '.sign' do
    it 'calls the Sign class' do
      arguments = double :arguments
      expect(JWTSignedRequest::Sign).to receive(:call).with(arguments)
      JWTSignedRequest.sign(arguments)
    end
  end

  describe '.verify' do
    it 'calls the Verify class' do
      arguments = double :arguments
      expect(JWTSignedRequest::Verify).to receive(:call).with(arguments)
      JWTSignedRequest.verify(arguments)
    end
  end
end
