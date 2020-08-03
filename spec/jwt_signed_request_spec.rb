# frozen_string_literal: true

require 'jwt_signed_request'

RSpec.describe JWTSignedRequest do
  describe '.configure_keys' do
    it 'adds verification keys to the default key store' do
      key = double
      expect(described_class.key_store).to receive(:add_verification_key).with(key)
      described_class.configure_keys do |config|
        config.add_verification_key(key)
      end
    end
  end

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
