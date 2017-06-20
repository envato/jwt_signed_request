# Using Version 1.X.X

Below is the documentation on how to use the gem for version 1.x.x

Please note that we are only supporting this functionaility for next first few releases of version 2.x.x
Look (over for details of new API)[https://github.com/envato/jwt_signed_request/blob/master/README.md].

## Signing Requests

If you are using an asymmetrical encryption algorithm such as ES256 you will sign your requests using the private key.

### Using net/http

```ruby
require 'net/http'
require 'uri'
require 'openssl'
require 'jwt_signed_request'

private_key = """
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
-----END EC PRIVATE KEY-----
"""

uri = URI('http://example.com')
req = Net::HTTP::Get.new(uri)

req['Authorization'] = JWTSignedRequest.sign(
  method: req.method,
  path: req.path,
  headers: {"Content-Type" => "application/json"},
  body: "",
  secret_key: OpenSSL::PKey::EC.new(private_key),
  algorithm: 'ES256',                     # optional (default: ES256)
  key_id: 'my-key-id',                    # optional
  issuer: 'my-issuer'                     # optional
  additional_headers_to_sign: ['X-AUTH']  # optional
)

res = Net::HTTP.start(uri.hostname, uri.port) {|http|
  http.request(req)
}
```

### Using faraday

```ruby
require 'faraday'
require 'openssl'
require 'jwt_signed_request/middlewares/faraday'

private_key = """
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
-----END EC PRIVATE KEY-----
"""

conn = Faraday.new(url: URI.parse('http://example.com')) do |faraday|
  faraday.use JWTSignedRequest::Middlewares::Faraday,
    secret_key: OpenSSL::PKey::EC.new(private_key),
    algorithm: 'ES256',                     # optional (default: ES256)
    key_id: 'my-key-id',                    # optional
    issuer: 'my-issuer',                    # optional
    additional_headers_to_sign: ['X-AUTH']  # optional

  faraday.adapter Faraday.default_adapter
end

conn.post do |req|
  req.url 'http://example.com'
  req.body = '{ "name": "Unagi" }'
end
```

## Verifying Requests

If you are using an asymmetrical encryption algorithm such as ES256 you will verify the request using the public key.

## Using Rails

```ruby
class APIController < ApplicationController
  PUBLIC_KEY = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/O
exDdlmXEjHYaixzYIduluGXd3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
-----END PUBLIC KEY-----
  """

  before_action :verify_request

  ...

  private

  def verify_request
    begin
      JWTSignedRequest.verify(
        request: request,
        secret_key: OpenSSL::PKey::EC.new(PUBLIC_KEY)
      )

    rescue JWTSignedRequest::UnauthorizedRequestError => e
      render :json => {}, :status => :unauthorized
    end
  end

end
```

### Increasing Expiry leeway

JWT tokens contain an expiry timestamp. If communication delays are large (or system clocks are sufficiently out of synch), you may need to increase the 'leeway' when verifying. For example:

```ruby
  JWTSignedRequest.verify(request: request, secret_key: 'my_public_key', leeway: 55)
```

## Using Rack Middleware

```ruby
PUBLIC_KEY = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/O
exDdlmXEjHYaixzYIduluGXd3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
-----END PUBLIC KEY-----
"""

class Server < Sinatra::Base
  use JWTSignedRequest::Middlewares::Rack,
     secret_key: OpenSSL::PKey::EC.new(PUBLIC_KEY),
     exclude_paths: /public|health/              # optional regex
 end
```
