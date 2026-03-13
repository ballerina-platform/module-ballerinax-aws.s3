# Multipart Uploads with AWS S3

This example demonstrates multipart upload operations for handling large files with Amazon S3 using the Ballerina AWS S3 connector. It showcases:

- Creating a multipart upload
- Uploading individual parts of a file
- Completing a multipart upload
- Aborting a multipart upload in case of failure

## Configuration

Create `Config.toml`:

```toml
accessKeyId = "YOUR_ACCESS_KEY_ID"
secretAccessKey = "YOUR_SECRET_ACCESS_KEY"
bucketName = "my-multipart-bucket"
```

## Run

```bash
bal run
```
