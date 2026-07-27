# Ballerina Amazon S3 Connector

[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.s3.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.s3)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.s3/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.s3)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.s3.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.s3./commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.s3/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.s3/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Amazon S3](https://aws.amazon.com/s3/) (Simple Storage Service) is a highly scalable, durable, and secure object storage service provided by Amazon Web Services (AWS). It is designed to store and retrieve any amount of data from anywhere on the web, making it ideal for a wide range of use cases, including data backup, archiving, content distribution, and big data analytics.

The `ballerinax/aws.s3` connector offers APIs to connect and interact with [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/API/Type_API_Reference.html), built on the AWS SDK v2. It supports creating, listing, and deleting buckets, uploading, retrieving, and deleting objects, managing object metadata and tagging, multipart uploads, and bucket and object access control lists (ACLs).

## Setup guide

To use the Ballerina AWS S3 connector, you need an AWS account with necessary credentials.

### Step 1: Sign in to AWS Console

1. If you don't have an AWS account yet, you can create one by visiting the AWS [sign-up](https://aws.amazon.com/free/) page. Sign up is free, and you can explore many services under the Free Tier.

2. If you already have an account, log into the [AWS Management Console](https://console.aws.amazon.com/console).

### Step 2: Create a user

1. In the AWS Management Console, search for **IAM** in the services search bar and click on it.

   ![create-user-1.jpeg](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-user-1.jpeg)

2. Click **Users**.

   ![create-user-2.jpeg](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-user-2.jpeg)

3. Click **Create User**.

   ![create-user-3.jpeg](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-user-3.jpeg)

4. Provide a suitable name for the user and continue.

   ![specify-user-details.jpeg](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/specify-user-details.jpeg)

5. Add necessary permissions by adding the user to a user group, copying permissions, or directly attaching policies. For S3, attach policies such as `AmazonS3FullAccess` (for development) or a least-privilege custom policy scoped to your buckets. Then click **Next**.

   ![set-user-permissions.jpeg](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/set-user-permissions.jpeg)

6. Review and create the user.

   ![review-create-user.jpeg](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/review-create-user.jpeg)

### Step 3: Get user access keys

1. Click the user who was created.

   ![users.jpeg](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/users.jpeg)

2. Click **Create access key**.

   ![create-access-key-1.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/create-access-key-1.png)

3. Select your use case and click **Next**.

   ![select-usecase.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/select-usecase.png)

4. Copy the **Access Key ID** and **Secret Access Key**. These credentials will be used to authenticate your Ballerina application with Amazon S3.

   ![retrieve-access-key.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.s3/refs/heads/master/docs/setup/resources/retrieve-access-key.png)

## Quickstart

To use the `aws.s3` connector in your Ballerina application, update your `.bal` file as follows.

### Step 1: Import the module

Import the `aws.s3` module and the `aws` module.

```ballerina
import ballerinax/aws;
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
   region: aws:US_EAST_1,
   auth: {
      accessKeyId,
      secretAccessKey
   }
});
```

#### Alternative authentication methods

##### Profile-based authentication

You can use AWS profile-based authentication as an alternative to static credentials.

```ballerina
final s3:Client s3Client = check new ({
   region: aws:US_EAST_1,
   auth: {
      profileName: "myAwsProfile",
      credentialsFilePath: "/path/to/custom/credentials"
   }
});
```

##### Default credential provider chain

The standard default credential provider chain, trying each of the following in order and taking the first source that yields credentials:

1. Environment variables (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`, and `AWS_WEB_IDENTITY_TOKEN_FILE` if set)
2. The shared config/credentials file's active profile (`AWS_PROFILE`, or `default` if unset) — which may itself resolve via SSO, an external process, or a chained `AssumeRole` call, depending on that profile's configuration
3. Container credentials (ECS/EKS)
4. EC2 instance profile (IMDS)

```ballerina
import ballerinax/aws.auth;

final s3:Client s3Client = check new ({
   region: aws:US_EAST_1,
   auth: auth:DEFAULT_CREDENTIALS
});
```

> **Note:** Ensure your AWS credentials file follows the standard format.
>
> ```ini
> [default]
> aws_access_key_id = YOUR_ACCESS_KEY_ID
> aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
>
> [myAwsProfile]
> aws_access_key_id = ANOTHER_ACCESS_KEY_ID
> aws_secret_access_key = ANOTHER_SECRET_ACCESS_KEY
> ```

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

## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:
   - [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
   - [OpenJDK](https://adoptium.net/)

   > **Note:** Set the `JAVA_HOME` environment variable to the path of the JDK installation.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToLocalCentral=true
   ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

- Discuss code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
- Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
- Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
