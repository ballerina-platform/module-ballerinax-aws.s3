## Overview

[Amazon S3](https://aws.amazon.com/s3/) (Simple Storage Service) is a highly scalable, durable, and secure object storage service provided by Amazon Web Services (AWS). It is designed to store and retrieve any amount of data from anywhere on the web, making it ideal for a wide range of use cases, including data backup, archiving, content distribution, and big data analytics.

The `ballerinax/aws.s3` connector offers APIs to connect and interact with [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html), specifically based on the `2006-03-01` version of the Amazon S3 REST API. It supports creating, listing, and deleting buckets, uploading, retrieving, and deleting objects, managing object metadata and tagging, multipart uploads, and bucket and object access control lists (ACLs).

## Setup guide

To use the Ballerina AWS S3 connector, you need an AWS account with necessary credentials.

### Step 1: Sign in to AWS Console

1. If you don't have an AWS account yet, you can create one by visiting the AWS [sign-up](https://aws.amazon.com/free/) page. Sign up is free, and you can explore many services under the Free Tier.

2. If you already have an account, log into the [AWS Management Console](https://console.aws.amazon.com/console).

### Step 2: Create a user

1. In the AWS Management Console, search for **IAM** in the services search bar and click on it.

   ![create-user-1.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-user-1.jpeg)

2. Click **Users**.

   ![create-user-2.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-user-2.jpeg)

3. Click **Create User**.

   ![create-user-3.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-user-3.jpeg)

4. Provide a suitable name for the user and continue.

   ![specify-user-details.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/specify-user-details.jpeg)

5. Add necessary permissions by adding the user to a user group, copying permissions, or directly attaching policies. For S3, attach policies such as `AmazonS3FullAccess` (for development) or a least-privilege custom policy scoped to your buckets. Then click **Next**.

   ![set-user-permissions.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/set-user-permissions.jpeg)

6. Review and create the user.

   ![review-create-user.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/review-create-user.jpeg)

### Step 3: Get user access keys

1. Click the user who was created.

   ![users.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/users.jpeg)

2. Click **Create access key**.

   ![create-access-key-1.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-access-key-1.png)

3. Select your use case and click **Next**.

   ![select-usecase.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/select-usecase.png)

4. Copy the **Access Key ID** and **Secret Access Key**. These credentials will be used to authenticate your Ballerina application with Amazon S3.

   ![retrieve-access-key.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/retrieve-access-key.png)

## Quickstart

To use the `aws.s3` connector in your Ballerina application, update your `.bal` file as follows.

### Step 1: Import the module

Import the `aws.s3` module.

```ballerina
import ballerinax/aws.s3;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the credentials obtained above:

```toml
accessKeyId = "<ACCESS_KEY_ID>"
secretAccessKey = "<SECRET_ACCESS_KEY>"
```

2. Instantiate an `s3:Client` with the obtained credentials and initialize the connector with it.

```ballerina
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

final s3:Client s3Client = check new ({
   region: s3:US_EAST_1,
   auth: {
      accessKeyId,
      secretAccessKey
   }
});
```

### Step 3: Invoke the connector operations

Now, utilize the available connector operations. A sample use case is shown below.

```ballerina
public function main() returns error? {
   check s3Client->createBucket("add-unique-bucket-name");
}
```

### Step 4: Run the Ballerina application

Use the following command to compile and run the Ballerina program.

```bash
bal run
```

## Examples

The `ballerinax/aws.s3` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples), covering the following use cases.

1. [S3 Report Archiver](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/s3-report-archiver): Implements an ETL-style workflow that processes CSV reports and archives them to Amazon S3. Reads report data, transforms it, and uploads the results to a designated S3 bucket for long-term storage.

2. [FTP to S3 Sync](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples/ftp-to-s3-sync): Syncs files from an FTP server to Amazon S3. Downloads files from the FTP source, uploads them to an S3 bucket, and generates a summary report of skipped or failed transfers.
