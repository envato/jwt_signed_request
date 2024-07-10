# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

### Changed

- Moved CI build to GitHub Actions ([#52]).
- Updated test matrix to test against the following gem versions, any gem versions outside of this matrix are no longer fully supported ([#58]):
  - `faraday`: `~> 1.10.0`, `~> 2.8.0`, `~> 2.9.0` & `~> 2.10.0`
  - `jwt`: `~> 1.5.0`, `~> 2.6.0`, `~> 2.7.0` & `~> 2.8.0`
  - `rack`: `~> 2.1.0`
- Removed support for Ruby 2.4 & 2.5 ([#58])
- Add Ruby 3.3 ([#56]), 3.2 ([#55]) to our test matrix

### Fixed

- Compatibility with Rack 3+ ([#58])

[#52]: https://github.com/envato/jwt_signed_request/pull/52
[#55]: https://github.com/envato/jwt_signed_request/pull/55
[#56]: https://github.com/envato/jwt_signed_request/pull/56
[#58]: https://github.com/envato/jwt_signed_request/pull/58

## [v3.0.0] - 2021-01-12

### Added

- Added support for Faraday version >= 1.2.0

### Changed

- Removed support for Ruby 2.3

## [v2.6.0] - 2020-08-05

### Added

- Support for multiple key stores

## [v2.5.4] - 2020-05-01

### Fixed

- Resolved deprecation warnings on ruby 2.7

### Changed

- Run CI tests against more ruby versions (added 2.6 and 2.7)

## [v2.5.3] - 2020-02-07

### Fixed

- Fixed an issue where the Faraday middleware empties request body in Faraday v1.0.0

## [v2.5.2] - 2020-02-06

### Changed

- Remove restriction on JWT version < 2.2

## [v2.5.1] - 2019-01-29

### Changed

- Added option `bearer_schema` to the Faraday middleware to allow the caller to specify whether to follow the [Bearer schema](https://auth0.com/docs/jwt#how-do-json-web-tokens-work-) when setting the JWT token in the Authorization request header (defaults to false)

## [v2.5.0] - 2019-01-21

### Changed

- Ensure we use the JWT Token in the Authorization header using the Bearer schema. We will still support Authorization headers without the Bearer schema

### Caveats

- Requests signed using version 2.5.0 can only be successfully verified by version 2.5.0. This will be addressed in version 2.5.1. To ensure compatibility it is recommended to skip this version or update the version of your request verifying service prior to the request signing service

## [v2.4.1] - 2019-01-08

### Changed

- Add support for JWT version 2.1

## [v2.4.0] - 2018-07-24

### Changed

- Added ability to configure verification leeway via the rack middleware

## [v2.3.0] - 2018-06-15

### Changed

- Use `JWT.decode` to extract the `kid` a JWT token.

## [v2.2.0] - 2018-04-05

### Changed

- Sort query string parameters before comparing them
- If request fails verification, raise error that indicates specifically what failed

## [v2.1.2] - 2017-09-15

### Changed

- Pass ownership to rubygems@envato.com
- Add contributors to README

## [v2.1.1] - 2017-09-14

### Changed

- Pin `jwt` gem dependency to version `1.5.x`, as the recent 2.0.0 release is currently incompatible with `jwt_signed_request`

## [v2.1.0] - 2017-08-31

### Changed

- Check `PATH_INFO` instead of `REQUEST_PATH` when performing path exclusion

## [v2.0.0] - 2017-06-21

### Changed

- Added ability to add signing and verifying keys to the `KeyStore`
- Changed API so users can instead provide a `key_id` when signing requests
- With requestes signed with a `key_id`, there is no need to provide a `secret_key` when verifying requests.
- Backwards compability with version 1.x.x

## [v1.2.2] - 2017-05-11

### Changed

- Fix minor claims releated errors from @twe4ked.

## [v1.2.0] - 2017-03-28

### Changed

- Allow configurable expiry leeway to verification
