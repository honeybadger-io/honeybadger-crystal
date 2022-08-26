# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Pending Release
### Added
- Implements the [filter_keys](https://docs.honeybadger.io/lib/ruby/getting-started/filtering-sensitive-data/) feature. (#27)
- Implements several additional overloads to Honeybadger.notify. (#29)
### Fixed
- AuthenticHandler is no longer required by default. See #28 for details on updating the honeybadger+lucky integration.

## [0.2.1] - 2022-01-20
### Added
- AuthenticHandler for easy configuration with Lucky Framework and Authentic. (#21, #23)

## [0.2.0] - 2021-09-07
### Added
- Allow implicit context variable declaration; scavenge data from crystal Log Context (#19)

### Fixed
- Refactor to open up context API typing to ease implementation (#18)

## [0.1.1] - 2021-06-29
### Added
- Allows Honeybadger configuration for development environments to be specified (#13)
- Updated crystal version specifier to allow Honeybadger to be used with Crystal 1.0. (#15)
- Allows Honeybadger config to be specified with environment variables (#16)
- Honeybadger.notify now accepts an optional second argument to specify the error context. (#17)

## [0.1.0] - 2021-04-13
- Initial crystal shard release
