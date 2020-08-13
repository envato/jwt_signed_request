# frozen_string_literal: true

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
