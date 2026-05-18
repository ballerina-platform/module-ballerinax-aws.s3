# FTP to S3 Sync

This example demonstrates a real-world integration use case of the Ballerina AWS S3 connector — syncing files from an FTP server to an AWS S3 bucket. It lists files on an FTP server, checks whether each file already exists in S3, downloads new files, uploads them to S3, and reports a sync summary.

## What It Demonstrates

| S3 Method | Used For |
|---|---|
| `doesObjectExist` | Check if a file is already in S3 before uploading |
| `putObject` | Upload downloaded FTP files to S3 |

## How It Works

For each file found on the FTP server:

1. Check if the file already exists in S3 — skip if it does
2. Download the file from FTP to a local temp directory
3. Upload the file to S3 under the configured prefix
4. Clean up the local temp file after upload
5. Report a full sync summary at the end

## Configuration

Create a `Config.toml` file and replace with actual values:

```toml
# AWS S3
s3AccessKeyId     = "<YOUR_ACCESS_KEY_ID>"
s3SecretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
s3BucketName      = "<YOUR_BUCKET_NAME>"
s3Region          = "us-east-1"
s3Prefix          = "ftp-synced"

# FTP Server
ftpHost      = "<FTP_HOST>"
ftpPort      = 21
ftpUser      = "<FTP_USERNAME>"
ftpPassword  = "<FTP_PASSWORD>"
ftpRemoteDir = "/"
```

### IAM Permissions Required

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:PutObject",
    "s3:GetObject",
    "s3:HeadObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "arn:aws:s3:::<YOUR_BUCKET_NAME>",
    "arn:aws:s3:::<YOUR_BUCKET_NAME>/*"
  ]
}
```

## Running the Example

**To build the example:**
```bash
cd ftp_to_s3_sync
bal build
```

**To run the example:**
```bash
cd ftp_to_s3_sync
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
