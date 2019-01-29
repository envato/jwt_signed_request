# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v2.5.0] - 2019-01-21

### Changed
- Ensure we use the JWT Token in the Authorization header using the Bearer schema. We will still support Authorization headers without the Bearer schema

### Breaking changes:
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
