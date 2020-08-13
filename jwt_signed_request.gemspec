lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jwt_signed_request/version'

Gem::Specification.new do |spec|
  spec.name          = "jwt_signed_request"
  spec.version       = JWTSignedRequest::VERSION

  spec.authors       = ["Envato"]
  spec.email         = ["rubygems@envato.com"]

  spec.summary       = %q{JWT request signing and verification for Internal APIs}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/envato/jwt_signed_request"

  spec.metadata      = {
                         'bug_tracker_uri'   => 'https://github.com/envato/jwt_signed_request/issues',
                         'changelog_uri'     => 'https://github.com/envato/jwt_signed_request/blob/master/CHANGELOG.md',
                         'source_code_uri'   => 'https://github.com/envato/jwt_signed_request',
                       }

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'jwt', '>= 1.5.0'
  spec.add_dependency 'rack'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
end
