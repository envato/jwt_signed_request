# JWT Signed Request
[![Test Suite](https://github.com/envato/jwt_signed_request/workflows/tests/badge.svg?branch=master)](https://github.com/envato/jwt_signed_request/actions?query=branch%3Amaster+workflow%3Atests)

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

We should be using a public key encryption algorithm such as **ES256**. To generate your public/private key pair using **ES256** run:

```sh
$ openssl ecparam -genkey -name prime256v1 -noout -out myprivatekey.pem
$ openssl ec -in myprivatekey.pem -pubout -out mypubkey.pem
```

Store and encrypt these in your application secrets.

## Configuration

You can add signing and verification keys to one or more key stores as your application needs them.

For example, given the following keys:

```ruby
private_key = <<-PEM.gsub(/^\s+/, "")
    -----BEGIN EC PRIVATE KEY-----
    MHcCAQEEIBOQ3YIILYMV1glTKbF9oeZWzHe3SNQjAx4IbPIxNygQoAoGCCqGSM49
    AwEHoUQDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/OexDdlmXEjHYaixzYIduluGXd
    3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
    -----END EC PRIVATE KEY-----
  PEM

public_key = <<-PEM.gsub(/^\s+/, "")
  -----BEGIN PUBLIC KEY-----
  MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEuOC3ufTTnW0hVmCPNERb4LxaDE/O
  exDdlmXEjHYaixzYIduluGXd3cjg4H2gjqsY/NCpJ9nM8/AAINSrq+qPuA==
  -----END PUBLIC KEY-----
PEM
```

### Single key store

If your application only needs a single key store, configure it like so:

```ruby
require 'openssl'

JWTSignedRequest.configure_keys do |config|
  config.add_signing_key(
    key_id: 'client_a',
    key: OpenSSL::PKey::EC.new(private_key),
    algorithm: 'ES256',
  )

  config.add_verification_key(
    key_id: 'client_a',
    key: OpenSSL::PKey::EC.new(public_key),
    algorithm: 'ES256',
  )
end
```

### Multiple key stores

If your application requires multiple key stores, configure them like so:

```ruby
key_store_id = 'widget_admin'

JWTSignedRequest.configure_keys(key_store_id) do |config|
  config.add_signing_key(
    key_id: 'client_a',
    key: OpenSSL::PKey::EC.new(private_key),
    algorithm: 'ES256',
  )

  config.add_verification_key(
    key_id: 'client_a',
    key: OpenSSL::PKey::EC.new(public_key),
    algorithm: 'ES256',
  )
end
```

## Signing Requests

If you have added your signing keys to a key store, you will only need to
specify the `key_id` you are signing the requests with.

If you are using multiple key stores, you will also need to pass the
appropriate `key_store_id`.

### Using net/http

```ruby
require 'net/http'
require 'uri'
require 'openssl'
require 'jwt_signed_request'

uri = URI('http://example.com')
req = Net::HTTP::Get.new(uri)
jwt_token = JWTSignedRequest.sign(
  method: req.method,
  path: req.path,
  headers: {"Content-Type" => "application/json"},
  body: "",
  key_id: 'my-key-id',                    # used for looking up key and kid header
  lookup_key_id: 'my-alt-key-id',         # optionally override lookup key
  key_store_id: 'widget_admin',           # optionally specify named key store ID
  issuer: 'my-issuer'                     # optional
  additional_headers_to_sign: ['X-AUTH']  # optional
)

req['Authorization'] = "Bearer #{jwt_token}"

res = Net::HTTP.start(uri.hostname, uri.port) {|http|
  http.request(req)
}
```

### Using Faraday

```ruby
require 'faraday'
require 'openssl'
require 'jwt_signed_request/middlewares/faraday'

conn = Faraday.new(url: URI.parse('http://example.com')) do |faraday|
  faraday.use(
    JWTSignedRequest::Middlewares::Faraday,
      key_id: 'my-key-id',
      key_store_id: 'my-key-store-id',        # optional
      issuer: 'my-issuer',                    # optional
      additional_headers_to_sign: ['X-AUTH'], # optional
      bearer_schema: true,                    # optional
    )

  faraday.adapter Faraday.default_adapter
end

conn.post do |req|
  req.url 'http://example.com'
  req.body = '{ "name": "Unagi" }'
end
```

#### Additional options

##### bearer_schema (boolean)

Determines whether to use the [Bearer schema](https://auth0.com/docs/jwt#how-do-json-web-tokens-work-) when assigning the JWT token to the `Authorization` request header

| bearer_schema value | Authorization header value|
|---------------------|---------------------------|
| false (default) | `<jwt_token>` |
| true | `Bearer <jwt_token>` |


## Verifying Requests

Please make sure you have added your verification keys to the appropriate key
store. Doing so will allow the server to verify requests signed by different
signing keys.

## Using Rails

```ruby
class APIController < ApplicationController
  before_action :verify_request

  ...

  private

  def verify_request
    begin
      JWTSignedRequest.verify(
        request: request,
        # Use optional `key_store_id` kwarg when working with multiple key stores, eg:
        key_store_id: 'widget_admin',
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
  JWTSignedRequest.verify(request: request, leeway: 55)
```

## Using Rack Middleware

```ruby
class Server < Sinatra::Base
  use(
    JWTSignedRequest::Middlewares::Rack,
    exclude_paths: /public|health/,          # optional regex
    leeway: 100,                             # optional
    key_store_id: 'my-key-store-id',         # optional
  )
 end
```

## Backwards Compability

Please note that the way we sign and verify requests has changed in version 2.x.x. For documentation on how to use older versions please look [here](https://github.com/envato/jwt_signed_request/blob/master/VERSION_1.md).

We are only supporting the old API for the next couple of releases of version 2.x.x so please upgrade ASAP.

## Maintainers
- [Envato](https://github.com/envato)

## License

`JWTSignedRequest` uses MIT license. See
[`LICENSE.txt`](https://github.com/envato/jwt_signed_request/blob/master/LICENSE.txt) for
details.

## Code of conduct

We welcome contribution from everyone. Read more about it in
[`CODE_OF_CONDUCT.md`](https://github.com/envato/jwt_signed_request/blob/master/CODE_OF_CONDUCT.md)

## Contributors

Many thanks to the following contributors to this gem:

- Toan Nguyen - [@yoshdog](https://github.com/yoshdog)
- Odin Dutton - [@twe4ked](https://github.com/twe4ked)
- Sebastian von Conrad - [@vonconrad](https://github.com/vonconrad)
- Zubin Henner- [@zubin](https://github.com/zubin)
- Glenn Tweedie - [@nocache](https://github.com/nocache)
- Giancarlo Salamanca - [@salamagd](https://github.com/salamagd)
- Ben Axnick - [@bentheax](https://github.com/bentheax)
- Glen Stampoultzis - [@gstamp](https://github.com/gstamp)
- Lucas Parry - [@lparry](https://github.com/lparry)
- Chris Mckenzie - [@chrisface](https://github.com/chrisface)

## Contributing

For bug fixes, documentation changes, and small features:

1. Fork it ( https://github.com/envato/jwt_signed_request/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

For larger new features: Do everything as above, but first also make contact with the project maintainers to be sure your change fits with the project direction and you won't be wasting effort going in the wrong direction

### Compatibility

Compatibility with multiple versions of the [JWT gem] is tested via the [appraisal gem].

Configured versions are defined in [Appraisals](./Appraisals), which at time of writing looked like this:

```ruby
# Latest JWT minor versions
# Source: https://rubygems.org/gems/jwt/versions
%w[
  1.5.6
  2.0.0
  2.1.0
  2.2.1
].each do |jwt_version|
```

Run the test suite like this:

```sh
# Test all configured versions
bundle exec appraisal rspec

# Target a specific configured version
bundle exec appraisal jwt-1.5.6 rspec
```

[JWT gem]: https://github.com/jwt/ruby-jwt
[appraisal gem]: https://github.com/thoughtbot/appraisal
