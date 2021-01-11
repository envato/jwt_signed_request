# frozen_string_literal: true

# Latest JWT minor versions
# Source: https://rubygems.org/gems/jwt/versions
%w[
  1.5.6
  2.0.0
  2.1.0
  2.2.1
].each do |jwt_version|
  appraise "jwt-#{jwt_version}" do
    gem "jwt", jwt_version
  end
end

# Latest Faraday minor versions
# Source: https://rubygems.org/gems/jwt/versions
%w[
  1.0.0
  1.1.0
  1.2.0
  1.3.0
].each do |faraday_version|
  appraise "faraday-#{faraday_version}" do
    gem "faraday", faraday_version, require: false
  end
end
