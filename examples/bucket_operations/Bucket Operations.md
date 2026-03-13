# Bucket Operations with AWS S3

This example demonstrates basic S3 bucket management operations with Amazon S3 using the Ballerina AWS S3 connector. It showcases:

- Creating a new bucket
- Listing all buckets in the account
- Retrieving the bucket location (AWS region)
- Deleting a bucket

## Configuration

Create `Config.toml`:

```toml
accessKeyId = "YOUR_ACCESS_KEY_ID"
secretAccessKey = "YOUR_SECRET_ACCESS_KEY"
bucketName = "my-test-bucket-12345"
```

**Note:** Bucket names must be globally unique across all AWS accounts.

## Run

```bash
bal run
```
