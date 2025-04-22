# Ballerina Amazon S3 Connector
[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.s3.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.s3)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.s3/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.s3)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.s3.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.s3./commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.s3/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.s3/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Amazon Simple Storage Service (Amazon S3)](https://aws.amazon.com/s3/) is an object storage service that offers industry-leading scalability, data availability, security, and performance. This means customers of all sizes and industries can use it to store and protect any amount of data for a range of use cases, such as data lakes, websites, mobile applications, backup and restore, archive, enterprise applications, IoT devices, and big data analytics.

## Overview

The Ballerina AWS S3 provides the capability to manage buckets and objects in [AWS S3](https://aws.amazon.com/s3/).

This module supports [Amazon S3 REST API](https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html) `2006-03-01` version.

## Compatibility
|                    | Version            |
|--------------------|--------------------|
| Ballerina Language | Swan Lake 2201.12.0|
| Amazon S3 API      | 2006-03-01         |

## Prerequisites

Before using this connector in your Ballerina application, complete the following:
1. Create an [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start)
2. [Obtain tokens](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

## Quickstart

To use the AWS S3 connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector

Import the `ballerinax/aws.s3` module into the Ballerina project.
```ballerina
import ballerinax/aws.s3;
```

### Step 2: Create a new connector instance

Create a `s3:ConnectionConfig` with the tokens obtained, and initialize the connector with it.

```ballerina
s3:ConnectionConfig amazonS3Config = {
    accessKeyId: <ACCESS_KEY_ID>,
    secretAccessKey: <SECRET_ACCESS_KEY>,
    region: <REGION>
};

s3:Client amazonS3Client = check new(amazonS3Config);
```

### Step 3: Invoke connector operation

1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.
Following is an example on how to create a bucket using the connector.

    ```ballerina
    string bucketName = "name";

    public function main() returns error? {
        _ = check amazonS3Client->createBucket(bucketName);
    }
    ```
2. Use `bal run` command to compile and run the Ballerina program.

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-aws.s3/tree/master/examples)**

## Building from the source

### Setting up the prerequisites
1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).

   > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/)

### Building the source

Execute the commands below to build from the source:
* To build the package:
   ```
   bal build ./ballerina
   ```
* To run the tests after build:
   ```
   bal test ./ballerina
   ```
## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community.

For more information, see [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* Discuss code changes of the Ballerina project via [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.

