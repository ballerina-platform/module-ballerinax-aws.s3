[![Build Status](https://travis-ci.org/wso2-ballerina/module-amazons3.svg?branch=master)](https://travis-ci.org/wso2-ballerina/module-amazons3)

# Ballerina Amazon S3 Client

The Amazon S3 client allows you to access the Amazon S3 REST API through ballerina. The following section provide you the details on client operations.

## Compatibility
| Ballerina Language Version | Amazon S3 API version  |
| -------------------------- | -------------------- |
| 0.991.0                    | 2006-03-01                  |

|                    |    Version     |
|:------------------:|:--------------:|
| Ballerina Language |   0.991.0      |
| Amazon S3 API      |   2006-03-01   |

## Pull and Install

### Pull the Module
You can pull the Amazon S3 client from Ballerina Central:
```ballerina
$ ballerina pull wso2/amazons3
```

### Install from Source
Alternatively, you can install AmazonS3 client from the source using the following instructions.

**Building the source**
1. Clone this repository using the following command:
```shell
    $ git clone https://github.com/wso2-ballerina/module-amazons3.git
    ```

2. Run this command from the `module-amazons3` root directory:

    ```shell
    $ ballerina build amazons3
    ```

**Installation**
You can install module-amazons3 using:
    ```shell
    $ ballerina install amazons3
    ```
This adds the amazons3 module into the Ballerina home repository.

## Running Tests

1. Create `ballerina.conf` file in `module-amazons3` with following configurations and provide appropriate value.

    ```
    ACCESS_KEY_ID="testAccessKeyValue"
    SECRET_ACCESS_KEY="testSecretAccessKeyValue"
    REGION="testRegion"
    BUCKET_NAME="testBucketName"
    ```

2. Navigate to the `module-amazons3` directory.

3. Run tests :

    ```ballerina
    ballerina init
    ballerina test amazons3
    ```
## How you can contribute

As an open source project, we welcome contributions from the community. Check the [issue tracker](https://github.com/wso2-ballerina/module-amazons3/issues) for open issues that interest you. We look forward to receiving your contributions.


