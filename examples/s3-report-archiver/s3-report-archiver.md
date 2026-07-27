# S3 Report Archiver with AWS S3

## Introduction

This guide demonstrates how to implement an ETL-style report processing pipeline using the Ballerina AWS S3 connector. The workflow covers scanning an S3 prefix for incoming CSV sales reports, transforming each report by filtering out zero-revenue rows, sorting by revenue descending, and adding a running total column, then uploading the processed output to a separate prefix, archiving the original, and deleting it from the incoming prefix to keep the bucket clean.

## Prerequisites

Follow the guidelines in the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-aws.s3#setup-guide) to obtain the necessary credentials to access the Amazon S3 API.

> **Note:** The IAM user must have `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket`, and `s3:HeadObject` permissions on your bucket.

### Configuration

Configure the AWS credentials and bucket details in `Config.toml` in the example directory.

```toml
s3AccessKeyId     = "<ACCESS_KEY_ID>"
s3SecretAccessKey = "<SECRET_ACCESS_KEY>"
s3BucketName      = "<BUCKET_NAME>"
s3Region          = "us-east-1"

incomingPrefix  = "reports/incoming/"
processedPrefix = "reports/processed/"
archivePrefix   = "reports/archive/"

maxFileSizeBytes = 10000000
```

## Run the example

Execute the following command to run the example.

```bash
bal run
```
