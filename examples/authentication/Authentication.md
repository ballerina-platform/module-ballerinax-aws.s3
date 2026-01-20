# Authentication with AWS S3

This example demonstrates authentication with Amazon S3 using the Ballerina AWS S3 connector. It showcases:

- Creating an S3 client with static credentials
- Listing all buckets to verify authentication
- Displaying the bucket count

## Configuration

Create `Config.toml`:

```toml
accessKeyId = "YOUR_ACCESS_KEY_ID"
secretAccessKey = "YOUR_SECRET_ACCESS_KEY"
```

## Run

```bash
bal run
```
