# FTP to S3 Sync with AWS S3

## Introduction

This example demonstrates how to upload files from an FTP server to an AWS S3 bucket using the Ballerina AWS S3 connector. It lists all files in a given FTP directory and uploads each one to S3.

## Prerequisites

Follow the guidelines in the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-aws.s3#setup-guide) to obtain the necessary credentials to access the Amazon S3 API.

### Configuration

Configure the AWS credentials and FTP server details in `Config.toml` in the example directory.

```toml
# AWS S3
s3AccessKeyId     = "<ACCESS_KEY_ID>"
s3SecretAccessKey = "<SECRET_ACCESS_KEY>"
s3BucketName      = "<BUCKET_NAME>"
s3Region          = "us-east-1"

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
