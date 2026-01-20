# AWS S3 Connector Examples

This directory contains comprehensive examples demonstrating various features and use cases of the Ballerina AWS S3 connector.

## Examples by Category

1. [**Authentication**](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/authentication) - Demonstrates how to authenticate with AWS S3 using static credentials.

2. [**Bucket Operations**](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/bucket-operations) - Shows how to create, list, get location, and delete S3 buckets.

3. [**Object Operations**](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/object-operations) - Demonstrates comprehensive object operations including upload/download with different content types (String, JSON, XML, Byte[]), metadata retrieval, copying, and existence checks.

4. [**Multipart Uploads**](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/multipart-uploads) - Shows how to handle large file uploads using S3 multipart upload API with multiple parts.

5. [**Stream Operations**](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/stream-operations) - Demonstrates memory-efficient streaming operations for uploading and downloading large files.

## Prerequisites

- Ballerina Swan Lake Update 8 or later
- AWS Account with S3 access
- AWS Access Key ID and Secret Access Key

## Configuration

Each example requires a `Config.toml` file with your AWS credentials:

```toml
accessKeyId = "<YOUR_ACCESS_KEY_ID>"
secretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
bucketName = "your-bucket-name"
```

## Running an Example

Execute the following commands to build and run an example:

### To build an example

```bash
cd <example-name>
bal build
```

### To run an example

```bash
cd <example-name>
bal run
```

## Building the Examples with the Local Module

**Warning:** Because of the absence of support for reading local repositories for single Ballerina files, the bala of
the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your
local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

### To build all the examples

```bash
./build.sh build
```

### To run all the examples

```bash
./build.sh run
```
