# Specification: Ballerina AWS S3 Connector

_Owners_: @Nuvindu \
_Reviewers_: @Nuvindu \
_Created_: 2025/01/01 \
_Updated_: 2026/09/08 \
_Edition_: Swan Lake

## Introduction

This is the specification for the AWS S3 connector of the [Ballerina language](https://ballerina.io/), which provides access to Amazon Simple Storage Service (S3) using the AWS SDK for Java V2.

The S3 connector specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/module-ballerinax-aws.s3/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` on GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

1. [Overview](#1-overview)
2. [Client](#2-client)
   * 2.1 [Initializing the Client](#21-initializing-the-client)
   * 2.2 [Bucket Operations](#22-bucket-operations)
   * 2.3 [Object Upload Operations](#23-object-upload-operations)
      * 2.3.1 [Data Binding for Uploads](#231-data-binding-for-uploads)
      * 2.3.2 [Streaming Uploads](#232-streaming-uploads)
   * 2.4 [Object Download Operations](#24-object-download-operations)
      * 2.4.1 [Data Binding for Downloads](#241-data-binding-for-downloads)
   * 2.5 [Object Management](#25-object-management)
   * 2.6 [Multipart Upload](#26-multipart-upload)
   * 2.7 [Presigned URLs](#27-presigned-urls)
3. [Errors](#3-errors)
   * 3.1 [Error Hierarchy](#31-error-hierarchy)
   * 3.2 [Error Handling](#32-error-handling)
4. [Observability](#4-observability)
   * 4.1 [Metrics](#41-metrics)
      * 4.1.1 [Gauges](#411-gauges)
      * 4.1.2 [Explicit Counters](#412-explicit-counters)
      * 4.1.3 [Derived Counters](#413-derived-counters)
   * 4.2 [Tags](#42-tags)
      * 4.2.1 [Identity Tags](#421-identity-tags)
      * 4.2.2 [Action Tags](#422-action-tags)
      * 4.2.3 [Outcome Tags](#423-outcome-tags)
      * 4.2.4 [File-Scoped Tags (Trace-Only)](#424-file-scoped-tags-trace-only)
      * 4.2.5 [Client Operation Tag Mapping](#425-client-operation-tag-mapping)
   * 4.3 [Tracing Structure](#43-tracing-structure)
   * 4.4 [Sample PromQL Queries](#44-sample-promql-queries)
   * 4.5 [Enabling Observability](#45-enabling-observability)
   * 4.6 [Observability Safety Rules](#46-observability-safety-rules)

## 1. Overview

Amazon Simple Storage Service (S3) is an object storage service that provides scalability, data availability, security, and performance. The Ballerina AWS S3 connector enables Ballerina programs to interact with S3 buckets and objects using the AWS SDK for Java V2.

The connector exposes a single core component:

- **Client** — The `s3:Client` connects to AWS S3 and performs bucket and object operations such as creating buckets, uploading, downloading, copying, and deleting objects, as well as multipart uploads and presigned URL generation.

The connector supports static credentials, profile-based credentials, and the default AWS credential provider chain (environment variables, ECS container credentials, EC2 instance profiles, etc.).

## 2. Client

The `s3:Client` connects to Amazon S3 and provides operations for managing buckets and objects. All client operations are isolated and can be called concurrently.

### 2.1 Initializing the Client

The `s3:Client` is initialized with a `ConnectionConfig` record that specifies the AWS region and authentication configuration. If initialization fails, an `s3:Error` is returned.

###### Example: Basic Client

```ballerina
s3:Client s3 = check new ({
    region: aws:US_EAST_1,
    auth: {
        accessKeyId: "AKIAIOSFODNN7EXAMPLE",
        secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }
});
```

###### Example: Client with Custom Endpoint (LocalStack)

```ballerina
s3:Client s3 = check new ({
    region: aws:US_EAST_1,
    auth: {
        accessKeyId: "test",
        secretAccessKey: "test"
    },
    endpoint: {
        customEndpoint: "http://localhost:4566"
    }
});
```

### 2.2 Bucket Operations

- `createBucket(bucketName, config)` — Creates a new S3 bucket with optional ACL, object ownership, and object lock configuration.
- `deleteBucket(bucketName)` — Deletes an empty S3 bucket.
- `listBuckets()` — Lists all buckets in the AWS account.
- `getBucketLocation(bucketName)` — Returns the AWS region of a bucket.

### 2.3 Object Upload Operations

#### 2.3.1 Data Binding for Uploads

The `putObject` method supports automatic serialization of content based on the object key extension or an explicit `fileFormat` configuration:

- `byte[]`, `string`, `json`, `xml` — Written directly.
- `record {}` — Serialized as JSON for `.json` keys, as XML for `.xml` keys.
- `record {}[]` — Serialized as CSV with field names as headers, requires `.csv` key.
- `stream<byte[], error?>` — Collected into bytes before uploading.
- `stream<record {}, error?>` — Serialized as CSV, requires `.csv` key.

###### Example: Uploading a JSON Record

```ballerina
type Order record {|
    int id;
    string item;
    decimal price;
|};

check s3->putObject("my-bucket", "orders/order1.json", {id: 1, item: "Widget", price: 9.99});
```

#### 2.3.2 Streaming Uploads

The `putObjectAsStream` method uploads content from a `stream<byte[], error?>` with a required `contentLength` parameter. This avoids loading the entire content into memory.

### 2.4 Object Download Operations

#### 2.4.1 Data Binding for Downloads

The `getObject` method supports automatic deserialization based on the object key extension and the target type:

- `byte[]` — Returns raw bytes.
- `string` — Returns UTF-8 encoded string.
- `json`, `xml` — Parses content accordingly.
- `record {}` — Parsed as JSON for `.json` keys, as XML for `.xml` keys.
- `record {}[]` — Parsed as CSV with first row as headers, requires `.csv` key.
- `stream<byte[], error?>` — Returns a byte stream for large objects.
- `stream<record {}, error?>` — Parses CSV and returns a record stream, requires `.csv` key.

###### Example: Downloading as a Typed Record

```ballerina
Order order = check s3->getObject("my-bucket", "orders/order1.json");
```

### 2.5 Object Management

- `deleteObject(bucketName, objectKey, config)` — Deletes an object with optional version ID and MFA support.
- `listObjects(bucketName, config)` — Lists objects with prefix filtering, delimiter grouping, and pagination.
- `getObjectMetadata(bucketName, objectKey, config)` — Returns object metadata without downloading content.
- `copyObject(sourceBucket, sourceKey, destBucket, destKey, config)` — Copies an object with full conditional and metadata options.
- `doesObjectExist(bucketName, objectKey)` — Returns `true` if the object exists, `false` if not found.

### 2.6 Multipart Upload

For large objects, the client supports multipart uploads:

- `createMultipartUpload(bucketName, objectKey, config)` — Initiates a multipart upload and returns an upload ID.
- `uploadPart(bucketName, objectKey, uploadId, partNumber, content, config)` — Uploads a part (1-10000) and returns its ETag. Supports the same content types as `putObject`.
- `uploadPartAsStream(bucketName, objectKey, uploadId, partNumber, contentStream, config)` — Uploads a part from a byte stream.
- `completeMultipartUpload(bucketName, objectKey, uploadId, partNumbers, etags)` — Finalizes the multipart upload.
- `abortMultipartUpload(bucketName, objectKey, uploadId)` — Cancels and cleans up an in-progress multipart upload.

### 2.7 Presigned URLs

- `createPresignedUrl(bucketName, objectKey, config)` — Generates a temporary URL for downloading (`GET`) or uploading (`PUT`) an object. Configurable expiration (default 15 minutes, maximum 7 days).

## 3. Errors

### 3.1 Error Hierarchy

The S3 connector defines a hierarchy of error types rooted at `s3:Error`. All S3-specific errors are distinct subtypes, enabling both specific and general error handling.

- **`Error`** — The base error type for all S3-related errors.
- **`NoSuchKeyError`** — The specified object key does not exist.
- **`BucketAlreadyExistsError`** — The bucket name is already taken by another AWS account.
- **`BucketAlreadyOwnedByYouError`** — The bucket already exists and is owned by you.
- **`NoSuchBucketError`** — The specified bucket does not exist.
- **`BucketNotEmptyError`** — The bucket is not empty and cannot be deleted.

### 3.2 Error Handling

Because all error types are subtypes of `s3:Error`, callers can handle errors at any level of specificity.

###### Example: Handling Specific Error Types

```ballerina
byte[]|s3:Error result = s3->getObject("my-bucket", "data/file.txt");
if result is s3:NoSuchKeyError {
    log:printWarn("Object not found");
} else if result is s3:NoSuchBucketError {
    log:printError("Bucket does not exist");
} else if result is s3:Error {
    log:printError("S3 operation failed", result);
} else {
    processBytes(result);
}
```

## 4. Observability

The S3 connector provides built-in observability support through metrics and distributed tracing, following the unified observability specification for Ballerina file integration libraries. When observability is enabled in the Ballerina runtime, the S3 client automatically reports telemetry data without any additional configuration.

The observability model is module-agnostic: the S3 connector publishes the same metric names and tag keys as other file integration modules (FTP, SMB, etc.). Module-specific values appear only in tag values (e.g. `module=s3`), never in metric names.

The S3 connector is a **client-only** connector. It does not have a listener, so listener-specific observability features (polling, file lifecycle stages, handler dispatch, post-processing cleanup) do not apply. Only client operation metrics and tracing are implemented.

### 4.1 Metrics

#### 4.1.1 Gauges

| Metric Name | Type | Description |
|---|---|---|
| `s3_active_connections` | Gauge | Number of active S3 client connections. Incremented on init, decremented on close — even if close errors. |

#### 4.1.2 Explicit Counters

| Metric Name | Type | Description |
|---|---|---|
| `file_bytes_transferred_total` | Counter | Total bytes read or written across operations. A sum of bytes, not a count of spans. |

`file_bytes_transferred_total` is incremented for:
- **Get operations** (`getObject` for non-stream return types) — carries `operation.type=get`
- **Put operations** (`putObject`, `putObjectFromFile`, `putObjectAsStream`, `uploadPart`, `uploadPartAsStream`) — carries `operation.type=put`

The `file_` prefix is shared across all file integration modules, enabling cross-module dashboards.

#### 4.1.3 Derived Counters

Client operation counts are derived from the Ballerina framework's built-in `requests_total_value` metric by filtering on the tags published on each span. No explicit counter needs to be published; the connector only ensures the correct tags are present on each span.

| Logical metric | Description | PromQL derivation |
|---|---|---|
| Client get operations | Object download operations | `requests_total_value{action_type="client_operation", module="s3", operation_type="get"}` |
| Client put operations | Object upload operations | `requests_total_value{action_type="client_operation", module="s3", operation_type="put"}` |
| Client manage operations | Bucket/object management operations | `requests_total_value{action_type="client_operation", module="s3", operation_type="manage"}` |

### 4.2 Tags

All metrics and trace spans carry tags that identify the connection, operation, and outcome.

> **Note:** Prometheus normalizes `.` to `_` in label names (e.g. `action.type` -> `action_type`, `operation.type` -> `operation_type`). Jaeger and other trace backends preserve the original dotted names. The PromQL examples in this section use the Prometheus-normalized form.

#### 4.2.1 Identity Tags

| Tag | Values | Metrics | Traces | Notes |
|---|---|---|---|---|
| `module` | `s3` | Yes | Yes | Identifies the Ballerina module. Always `s3`. |
| `protocol` | `https`, `http` | Yes | Yes | The wire protocol. `https` for standard AWS endpoints, `http` when using a custom HTTP endpoint (e.g. LocalStack). |
| `type` | `client` | Yes | Yes | Always `client` — S3 connector has no listener. |
| `remote.url` | S3 endpoint URL | Yes | Yes | For standard endpoints: `s3.{region}.amazonaws.com`. For custom endpoints: the configured URL. |
| `host` | Local hostname | Yes | Yes | Hostname of the current instance. Lazily resolved on first use. |

#### 4.2.2 Action Tags

| Tag | Values | Metrics | Traces | Notes |
|---|---|---|---|---|
| `action.type` | `client_operation` | Yes | Yes | Always `client_operation` for S3 client operations. |
| `operation.type` | `get`, `put`, `manage` | Yes | Yes | Categorizes the operation. See [Section 4.2.5](#425-client-operation-tag-mapping) for the full mapping. |

#### 4.2.3 Outcome Tags

| Tag | Values | Metrics | Traces | Notes |
|---|---|---|---|---|
| `outcome` | `success`, `failure` | Yes | Yes | Binary result of the operation. |
| `error.type` | `Error`, `NoSuchKeyError`, `NoSuchBucketError`, `BucketAlreadyExistsError`, `BucketAlreadyOwnedByYouError`, `BucketNotEmptyError`, ... | Yes | Yes | Present when `outcome=failure`. Set to the Ballerina error type name. |

#### 4.2.4 File-Scoped Tags (Trace-Only)

| Tag | Values | Metrics | Traces | Notes |
|---|---|---|---|---|
| `file.path` | S3 object key | No | Yes | Excluded from metrics to avoid cardinality explosion. Set on all operations that operate on a specific object. |
| `destination.path` | Destination object key | No | Yes | Excluded from metrics. Set on `copyObject` to identify the destination. |

#### 4.2.5 Client Operation Tag Mapping

All client operation spans use `type=client` and `action.type=client_operation`. The `operation.type` tag maps to the client method:

| `operation.type` | Triggered by |
|---|---|
| `get` | `getObject` (all target types) |
| `put` | `putObject`, `putObjectFromFile`, `putObjectAsStream`, `createMultipartUpload`, `uploadPart`, `uploadPartAsStream`, `completeMultipartUpload` |
| `manage` | `createBucket`, `deleteBucket`, `listBuckets`, `getBucketLocation`, `deleteObject`, `listObjects`, `getObjectMetadata`, `copyObject`, `doesObjectExist`, `abortMultipartUpload`, `createPresignedUrl` |

### 4.3 Tracing Structure

The S3 connector enriches the auto-instrumented spans that the Ballerina runtime creates for each `remote` method call. Each span is tagged with the S3-specific tags described above.

```
Client Operation Span (action.type=client_operation)
├── module = s3
├── type = client
├── remote.url = s3.us-east-1.amazonaws.com
├── protocol = https
├── operation.type = get | put | manage
├── outcome = success | failure
├── error.type = ... (on failure)
├── host = hostname
└── [span-only] file.path = object/key
                 destination.path = dest/key (copyObject only)
```

For operations that transfer data, the `file_bytes_transferred_total` counter is incremented with the byte count after a successful transfer.

### 4.4 Sample PromQL Queries

```promql
# ---- Client operations by type ----
rate(requests_total_value{action_type="client_operation", module="s3", operation_type="get"}[5m])
rate(requests_total_value{action_type="client_operation", module="s3", operation_type="put"}[5m])
rate(requests_total_value{action_type="client_operation", module="s3", operation_type="manage"}[5m])

# ---- Error rate by error type ----
sum by (error_type) (
  rate(requests_total_value{action_type="client_operation", module="s3", outcome="failure"}[5m])
)

# ---- Success rate ----
rate(requests_total_value{action_type="client_operation", module="s3", outcome="success"}[5m])

# ---- Bytes transferred ----
rate(file_bytes_transferred_total{module="s3", operation_type="get"}[5m])    # bytes downloaded
rate(file_bytes_transferred_total{module="s3", operation_type="put"}[5m])    # bytes uploaded

# ---- Active connections ----
s3_active_connections

# ---- Cross-module: total bytes across S3, FTP, SMB ----
rate(file_bytes_transferred_total[5m])

# ---- Cross-module: all client operations across all file modules ----
rate(requests_total_value{action_type="client_operation"}[5m])
```

### 4.5 Enabling Observability

Observability must be enabled in the Ballerina runtime configuration. Add the following to `Config.toml`:

```toml
[ballerina.observe]
metricsEnabled=true
metricsReporter="prometheus"
tracingEnabled=true
tracingProvider="jaeger"
```

Refer to the [Ballerina Observability documentation](https://ballerina.io/learn/observe-ballerina-programs/) for details on configuring reporters and exporters.

### 4.6 Observability Safety Rules

Observability must never break S3 operations. All metric and tracing calls are guarded by the following rules:

1. **Exception isolation.** Every public method in the metrics and tracing utilities wraps its body in `try/catch(Throwable)` and swallows the exception. A registry error, NPE, or any other observability failure must never propagate to callers. This follows the same pattern used by the FTP module and `module-ballerina-sql`.

2. **Early guard.** All metric methods check `ObserveUtils.isMetricsEnabled()` and return immediately when metrics are disabled. Tracing methods check for a valid `ObserverContext` on the current frame and exit early if none is found. This ensures zero overhead when observability is off.

3. **Cardinality control.** Object keys (`file.path`, `destination.path`) are added only to trace spans, never to metric labels. This prevents unbounded cardinality in Prometheus time series.
