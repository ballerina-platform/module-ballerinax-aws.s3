## Overview
The Ballerina AWS S3 provides the capability to manage buckets and objects in [AWS S3](https://aws.amazon.com/s3/).

This module supports [Amazon S3 REST API](https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html) `2006-03-01` version.
 
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
