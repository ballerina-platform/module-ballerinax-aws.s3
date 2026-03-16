# S3 Scheduled Report Archiver

This example demonstrates a real-world ETL pipeline using the Ballerina AWS S3 connector.
It scans an S3 prefix for incoming CSV sales reports, transforms each one, writes the
processed output back to S3, archives the original, and deletes it from the incoming prefix —
keeping the bucket clean and organised automatically.

## What It Demonstrates

| S3 Method | Used For |
|---|---|
| `listObjects` | Scan the incoming prefix for CSV files |
| `getObjectMetadata` | Check file size and last-modified before downloading |
| `getObjectAsCsv` | Read the report directly as structured `string[][]` |
| `putObject` | Upload the transformed CSV to the processed prefix |
| `copyObject` | Archive the original before deleting it |
| `deleteObject` | Remove the processed original from incoming |


## What the Transformation Does

For each incoming CSV report the archiver:

1. Filters out rows with zero or negative revenue
2. Sorts remaining rows by revenue descending
3. Adds a `running_total` column
4. Writes the result as a new CSV to the processed prefix

**Input (`sales_january.csv`):**
```
date,product,region,units,revenue
2025-01-01,Widget A,North,120,2400.00
2025-01-02,Widget C,East,0,0.00        ← filtered out (zero revenue)
2025-01-03,Widget D,South,310,9300.00
...
```

**Output (`sales_january_processed.csv`):**
```
date,product,region,units,revenue,running_total
2025-01-03,Widget D,South,310,9300.0,9300.0    ← sorted by revenue desc
2025-01-02,Widget A,West,200,4000.0,13300.0
2025-01-04,Widget C,West,150,3000.0,16300.0
...
```

## IAM Permissions Required

The IAM user must have the following permissions on your bucket:

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:HeadObject"
  ],
  "Resource": [
    "arn:aws:s3:::<YOUR_BUCKET_NAME>",
    "arn:aws:s3:::<YOUR_BUCKET_NAME>/*"
  ]
}
```

## Configuration

Fill in your credentials and bucket details in `Config.toml`:

```toml
s3AccessKeyId     = "<YOUR_ACCESS_KEY_ID>"
s3SecretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
s3BucketName      = "<YOUR_BUCKET_NAME>"
s3Region          = "us-east-1"

incomingPrefix  = "reports/incoming/"
processedPrefix = "reports/processed/"
archivePrefix   = "reports/archive/"

maxFileSizeBytes = 10000000
```

## Running the Example

**To build the example:**
```bash
cd s3_report_archiver
bal build
```

**To run the example:**
```bash
cd s3_report_archiver
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
