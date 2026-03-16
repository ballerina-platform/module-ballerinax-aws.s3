# AWS S3 Connector Examples

This directory contains examples demonstrating real-world use cases of the Ballerina AWS S3 connector.

## Examples

### 1. [S3 Report Archiver](./s3_report_archiver/README.md)

Scans an S3 prefix for incoming CSV sales reports, transforms each one (filters zero-revenue rows, sorts by revenue, adds a running total), uploads the processed output to a separate prefix, archives the original, and deletes it from the incoming prefix.

**Key methods:** `listObjects`, `getObjectMetadata`, `getObjectAsCsv`, `putObject`, `copyObject`, `deleteObject`

### 2. [FTP to S3 Sync](./ftp_to_s3_sync/README.md)

Syncs files from an FTP server to an AWS S3 bucket. Lists files on the FTP server, skips files already present in S3, downloads new files, and uploads them under a configured S3 prefix.

**Key methods:** `doesObjectExist`, `putObject`

## Configuration

Each example requires a `Config.toml` file with your AWS credentials. Refer to the README inside each example directory for the full configuration reference.

```toml
s3AccessKeyId     = "<YOUR_ACCESS_KEY_ID>"
s3SecretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
s3BucketName      = "<YOUR_BUCKET_NAME>"
```

## Running an Example

**To build an example:**
```bash
cd <example-name>
bal build
```

**To run an example:**
```bash
cd <example-name>
bal run
```

**To build all the examples:**
```bash
./build.sh build
```

**To run all the examples:**
```bash
./build.sh run
```
