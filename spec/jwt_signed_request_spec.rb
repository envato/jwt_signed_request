# frozen_string_literal: true

require 'jwt_signed_request'

RSpec.describe JWTSignedRequest do
  describe '.sign' do
    it 'calls the Sign class' do
      arguments = { arg: double }
      expect(described_class::Sign).to receive(:call).with(arguments)
      described_class.sign(**arguments)
    end
  end

  describe '.verify' do
    it 'calls the Verify class' do
      arguments = { arg: double }
      expect(described_class::Verify).to receive(:call).with(arguments)
      described_class.verify(**arguments)
    end
  end
end
