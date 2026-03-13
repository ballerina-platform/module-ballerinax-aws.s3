# Object Operations with AWS S3

This example demonstrates comprehensive object operations with Amazon S3 using the Ballerina AWS S3 connector. It showcases:

- Uploading objects (supporting String, JSON, XML, and Byte Array content types)
- Downloading objects with automatic type conversion
- Retrieving object metadata without downloading content
- Checking if an object exists
- Copying objects within or across buckets
- Listing objects in a bucket
- Deleting objects from a bucket

## Configuration

Create `Config.toml`:

```toml
accessKeyId = "YOUR_ACCESS_KEY_ID"
secretAccessKey = "YOUR_SECRET_ACCESS_KEY"
bucketName = "my-object-bucket"
```

## Run

```bash
bal run
```
