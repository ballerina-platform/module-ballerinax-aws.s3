# Examples

The `ballerinax/aws.s3` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples).

1. [S3 Report Archiver](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/s3-report-archiver)

   This example shows how to implement a report processing pipeline. It scans for incoming CSV sales reports, transforms each one by filtering zero-revenue rows, sorting by revenue, and adding a running total column, then uploads the processed output to a separate prefix and archives the original.

2. [FTP to S3 Sync](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/ftp-to-s3-sync)

   This example shows how to upload files from an FTP server to an AWS S3 bucket. It lists all files in a given FTP directory and uploads each one to S3.

## Prerequisites

1. Follow the [instructions](https://github.com/ballerina-platform/module-ballerinax-aws.s3#setup-guide) to set up the Amazon S3 API.

2. For each example, create a `Config.toml` file in the example directory with your AWS credentials. Here is an example of how your `Config.toml` file should look:

   ```toml
   s3AccessKeyId     = "<ACCESS_KEY_ID>"
   s3SecretAccessKey = "<SECRET_ACCESS_KEY>"
   s3Region          = "<AWS_REGION>"
   s3BucketName      = "<BUCKET_NAME>"
   ```

   Refer to the README inside each example directory for the full configuration reference.

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

  ```bash
  bal build
  ```

* To run an example:

  ```bash
  bal run
  ```

## Building the Examples with the Local Module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

  ```bash
  ./build.sh build
  ```

* To run all the examples:

  ```bash
  ./build.sh run
  ```
