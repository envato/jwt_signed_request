# JWT Signed Request
[![travis ci build](https://api.travis-ci.org/envato/jwt_signed_request.svg)](https://travis-ci.org/envato/jwt_signed_request)

Request signing and verification for Internal APIs using JWT.

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'jwt_signed_request'
```

then run:

```sh
$ bundle
```

## Generating EC Keys

We should be using a public key encryption alogorithm such as **ES256**. To generate your public/private key pair using **ES256** run:

```sh
$ openssl ecparam -genkey -name prime256v1 -noout -out myprivatekey.pem
$ openssl ec -in myprivatekey.pem -pubout -out mypubkey.pem
```

Store and encrypt these in your application secrets.

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
    algorithm: 'EC256',                     # optional (default: ES256)
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

## Using Rack Middleware

```ruby
PUBLIC_KEY = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/O
exDdlmXEjHYaixzYIduluGXd3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
-----END PUBLIC KEY-----
"""

class Server < Sinatra::Base
  use JWTSignedRequest::Middlewares::Rack
     secret_key: OpenSSL::PKey::EC.new(PUBLIC_KEY)
 end
```

## Maintainers
- [Toan Nguyen](https://github.com/yoshdog)

## License

`JWTSignedRequest` uses MIT license. See
[`LICENSE.txt`](https://github.com/envato/jwt_signed_request/blob/master/LICENSE.txt) for
details.

## Code of conduct

We welcome contribution from everyone. Read more about it in
[`CODE_OF_CONDUCT.md`](https://github.com/envato/jwt_signed_request/blob/master/CODE_OF_CONDUCT.md)

## Contributing

For bug fixes, documentation changes, and small features:

1. Fork it ( https://github.com/envato/jwt_signed_request/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

For larger new features: Do everything as above, but first also make contact with the project maintainers to be sure your change fits with the project direction and you won't be wasting effort going in the wrong direction
