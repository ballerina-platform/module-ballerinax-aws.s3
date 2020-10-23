[![Build Status](https://travis-ci.org/ballerina-platform/module-amazons3.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-amazons3)

# Ballerina Amazon S3 Client

The Amazon S3 client allows you to access the Amazon S3 REST API through Ballerina. The following sections provide the details on client operations.

## Compatibility
| Ballerina Language Version | Amazon S3 API version  |
| -------------------------- | ---------------------- |
|     Swan Lake Preview4     |       2006-03-01       |


## Pull and Install

### Pull the Module
You can pull the Amazon S3 client from Ballerina Central:
```shell
$ ballerina pull ballerinax/aws.s3
```

### Install from Source
Alternatively, you can install AmazonS3 client from the source using the following instructions.

**Building the source**
1. Clone this repository using the following command:
    ```shell
    $ git clone https://github.com/ballerina-platform/module-amazons3.git
    ```

2. Run this command from the `module-amazons3` root directory:
    ```shell
    $ ballerina build aws.s3
    ```


## Running Tests

1. Create `ballerina.conf` file in `module-amazons3` with the following configurations and provide appropriate value.

    ```
    ACCESS_KEY_ID="testAccessKeyValue"
    SECRET_ACCESS_KEY="testSecretAccessKeyValue"
    REGION="testRegion"
    BUCKET_NAME="testBucketName"
    ```

2. Navigate to the `module-amazons3` directory.

3. Run tests :

    ```ballerina
    ballerina test aws.s3
    ```

## How you can contribute

As an open source project, we welcome contributions from the community. Check the [issue tracker](https://github.com/ballerina-platform/module-amazons3/issues) for open issues that interest you. We look forward to receiving your contributions.
