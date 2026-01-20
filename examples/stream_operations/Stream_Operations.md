# Stream Operations with AWS S3

This example demonstrates efficient streaming operations for uploads and downloads with Amazon S3 using the Ballerina AWS S3 connector. It showcases:

- Uploading objects using streaming (memory efficient)
- Downloading objects using streaming
- Uploading multipart parts using streaming

## Configuration

Create `Config.toml`:

```toml
accessKeyId = "YOUR_ACCESS_KEY_ID"
secretAccessKey = "YOUR_SECRET_ACCESS_KEY"
bucketName = "my-stream-bucket"
```

## Run

```bash
bal run
```
