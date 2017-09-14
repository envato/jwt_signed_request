# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v1.2.0] - 2017-03-28
### Changed
- Allow configurable expiry leeway to verification

## [v1.2.2] - 2017-05-11
### Changed
- Fix minor claims releated errors from @twe4ked.

## [v2.0.0] - 2017-06-21
### Changed
- Added ability to add signing and verifying keys to the `KeyStore`
- Changed API so users can instead provide a `key_id` when signing requests
- With requestes signed with a `key_id`, there is no need to provide a `secret_key` when verifying requests.
- Backwards compability with version 1.x.x

## [v2.1.0] - 2017-08-31
### Changed
- Check `PATH_INFO` instead of `REQUEST_PATH` when performing path exclusion

## [v2.1.1] - 2017-09-14
### Changed
- Pin `jwt` gem dependency to version `1.5.x`, as the recent 2.0.0 release is currently incompatible with `jwt_signed_request`
