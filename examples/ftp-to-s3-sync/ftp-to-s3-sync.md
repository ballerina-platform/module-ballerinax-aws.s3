# FTP to S3 Sync with AWS S3

## Introduction

This guide demonstrates how to sync files from an FTP server to an AWS S3 bucket using the Ballerina AWS S3 connector. The workflow covers listing files on the FTP server, skipping files already present in S3, downloading new files from FTP, uploading them to S3 under a configured prefix, cleaning up local temp files after each upload, and producing a full sync summary report at the end.

## Prerequisites

Follow the guidelines in the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-aws.s3#setup-guide) to obtain the necessary credentials to access the Amazon S3 API.

> **Note:** The IAM user must have `s3:PutObject`, `s3:GetObject`, `s3:HeadObject`, and `s3:ListBucket` permissions on your bucket.

### Configuration

Configure the AWS credentials and FTP server details in `Config.toml` in the example directory.

```toml
# AWS S3
s3AccessKeyId     = "<ACCESS_KEY_ID>"
s3SecretAccessKey = "<SECRET_ACCESS_KEY>"
s3BucketName      = "<BUCKET_NAME>"
s3Region          = "us-east-1"
s3Prefix          = "ftp-synced"

# FTP Server
ftpHost      = "<FTP_HOST>"
ftpPort      = 21
ftpUser      = "<FTP_USERNAME>"
ftpPassword  = "<FTP_PASSWORD>"
ftpRemoteDir = "/"
```

## Run the example

Execute the following command to run the example.

```bash
bal run
```
