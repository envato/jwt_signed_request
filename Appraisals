# frozen_string_literal: true

# Latest JWT minor versions
# Source: https://rubygems.org/gems/jwt/versions
%w[
  1.5.0
  2.6.0
  2.7.0
  2.8.0
].each do |jwt_version|
  appraise "jwt-#{jwt_version}" do
    gem 'jwt', "~> #{jwt_version}"
  end
end

# Latest Faraday minor versions
# Source: https://rubygems.org/gems/faraday/versions
%w[
  1.10.0
  2.8.0
  2.9.0
  2.10.0
].each do |faraday_version|
  appraise "faraday-#{faraday_version}" do
    gem 'faraday', "~> #{faraday_version}", require: false
  end
end

# Latest Rack minor versions
# Source: https://rubygems.org/gems/rack/versions
%w[
  2.1.0
  2.2.0
  3.0.0
  3.1.0
].each do |rack_version|
  appraise "rack-#{rack_version}" do
    gem 'rack', "~> #{rack_version}"
  end
end
