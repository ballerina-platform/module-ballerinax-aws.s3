# Change Log
This file contains all the notable changes done to the Ballerina AWS S3 package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- Updated Netty to 4.2.18.Final, replacing the `netty-codec` artifact with `netty-codec-base` ([#9152](https://github.com/ballerina-platform/ballerina-library/issues/9152))
- Updated the minimum required Ballerina distribution to 2201.14.0 (Swan Lake Update 14). Netty 4.1 and 4.2 cannot co-exist on a class path, and the `ballerina/http` bundled in earlier distributions ships Netty 4.1

## [4.0.0] - 2026-08-05

### Added

- [Revamp the S3 connector](https://github.com/ballerina-platform/ballerina-library/issues/8500)
- Add AWS native authentication support for the AWS S3 connector

### Changed

- Updated `ConnectionConfig` to use the shared `auth:AuthConfig` from `ballerinax/aws.auth` and `aws:Region` from `ballerinax/aws` for authentication and region configuration
- Replaced `getObject`, `getObjectAsStream`, `getObjectAsText`, `getObjectAsJson`, `getObjectAsXml`, and `getObjectAsCsv` with a single `getObject` method that supports compile-time type inference via `typedesc`
- The unified `getObject` method supports `byte[]`, `string`, `json`, `xml`, `record {}`, `record {}[]`, `stream<byte[], error?>`, and `stream<record {}, error?>` as target types
- For `record {}`, the object key must end with `.json` or `.xml` (`.json` for JSON parsing, `.xml` for XML parsing)
- For `record {}[]`, the content is parsed as CSV with the first row treated as headers
- Expanded `putObject` to accept `record {}`, `record {}[]`, `stream<byte[], error?>`, and `stream<record {}, error?>` in addition to the existing `byte[]`, `string`, `json`, and `xml` types
- `record {}` content is serialized as JSON; `record {}[]` and `stream<record {}, error?>` content is serialized as CSV
- Introduced distinct error types and restructured configuration records
