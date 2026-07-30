# Change Log
This file contains all the notable changes done to the Ballerina AWS S3 package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- [Revamp the S3 connector](https://github.com/ballerina-platform/ballerina-library/issues/8500)
- Add AWS native authentication support for the AWS S3 connector

### Changed

- Migrated the underlying implementation from pure Ballerina HTTP-based approach to Java-based AWS SDK v2
- Replaced `ConnectionConfig` with `auth:AuthConfig`, supporting multiple authentication methods (static credentials, profiles, default provider chain)
- Renamed `objectName` parameter to `objectKey` across all APIs
- Replaced `createObject()` with `putObject()`, `putObjectFromFile()`, and `putObjectAsStream()`
- Added new retrieval methods: `getObjectAsText()`, `getObjectAsJson()`, `getObjectAsXml()`, `getObjectAsCsv()`, and `getObjectMetadata()`
- Added `copyObject()`, `doesObjectExist()`, `getBucketLocation()`, and `close()` methods
- Changed `listObjects()` to return `ListObjectsResponse` instead of `S3Object[]`
- Replaced generic `error` return types with distinct `Error` type and specific error subtypes (`NoSuchKeyError`, `BucketAlreadyExistsError`, etc.)
- Restructured configuration records (`ObjectCreationHeaders` → `PutObjectConfig`, `ObjectRetrievalHeaders` → `GetObjectConfig`, etc.)
- Changed `completeMultipartUpload()` to accept separate `int[]` and `string[]` arrays instead of `CompletedPart[]`
- Replaced `ObjectAction` enum with `HttpMethod` in `createPresignedUrl()`
