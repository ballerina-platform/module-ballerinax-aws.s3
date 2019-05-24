Connects to Amazon S3 from Ballerina. 

# Module Overview

The Amazon S3 connector allows you to access the Amazon S3 REST API through ballerina. The following section provide you the details on connector operations.


**Buckets Operations**

The `wso2/amazons3` module contains operations that work with buckets. You can list the existing buckets, create a bucket,
delete a bucket and list objects in a bucket.

**Objects Operations**

The `wso2/amazons3` module contains operations that create an object, delete an object and retrieve an object.



## Compatibility
|                    |    Version     |  
|:------------------:|:--------------:|
| Ballerina Language |   0.991.0      |
| Amazon S3 API      |   2006-03-01   |


## Sample

First, import the `wso2/amazons3` module into the Ballerina project.

```ballerina
import wso2/amazons3;
```
    
The Amazon S3 connector can be instantiated using the accessKeyId, secretAccessKey, securityToken, region
and bucketName in the Amazon S3 client config.

**Obtaining AWS credentials to Run the Sample**

## Signing Up for AWS

1. Navigate to [Amazon] (#https://aws.amazon.com/), and then click **Create an AWS Account**.

   **Note:** If you previously signed in to the AWS Management Console using the root user credentials of the AWS account, click **Sign in** to use a different account. If you previously signed in to the console using the IAM credentials, sign in using the credentials of the root account.
2. Then, click **Create a new AWS account** and follow the given instructions.

Follow either of the methods explained below to obtain AWS credentials.

### Obtaining user credentials

You can access the Amazon S3 service using the root user credentials. However, these credentials allow full access to all the resources in the account as you cannot restrict permission for root user credentials.
If you want to restrict certain resources and allow controlled access to AWS services, then you can create IAM (Identity and Access Management) users in your AWS account. Follow the steps below to do this.

###### Follow the steps below to get an AWS Access Key for your AWS root account:

1. Log in to the AWS Management Console.
2. Hover over your company name in the right top menu and click **My Security Credentials**.
3. Scroll down to the **Access Keys** section.
4. Click **Create New Access Key**.
5. Copy both the Access Key ID (YOUR_AMAZON_S3_KEY) and Secret Access Key (YOUR_AMAZON_S3_SECRET).

###### Follow the steps below to get an AWS Access Key for an IAM user account:

1. Sign in to the AWS Management Console and open the IAM Console.
2. In the navigation pane, click **Users**.
3. Select the name of the desired user, and then click **User Actions** from the top menu.
4. Click **Manage Access Keys**.
5. Click **Create Access Key**.
6. Click **Show User Security Credentials**.
7. Copy and paste the Access Key ID and Secret Access Key values or click **Download Credentials** to download the credentials as a CSV (file).
8. Obtain the following parameters:

* Access key ID
* Secret access key
* Desired server region

### Obtaining temporary security credentials

An AWS Account or an IAM user can request temporary security credentials and use them to send authenticated requests to Amazon S3.

1. Obtain temporary security credentials and use them to authenticate your requests to Amazon S3. For instructions, go to the  [S3 documentation] (https://docs.aws.amazon.com/AmazonS3/latest/dev/AuthUsingTempSessionToken.html) to try out the provided examples on how to use the AWS SDK for Java, .NET, and PHP.

2. Obtain the following parameters:
    * Access key ID
    * Secret access key
    * Token
    * Desired server region


You can now enter the credentials in the Amazon S3 client config:
```ballerina
amazons3:AmazonS3Configuration amazonS3Config = {
    accessKeyId: testAccessKeyId,
    secretAccessKey: testSecretAccessKey,
    securityToken: testSecurityToken,
    region: testRegion,
    amazonHost: amazonHost
};
amazons3:Client amazonS3Client = new(amazonS3Config);
```

The `createBucket` remote function creates a bucket.
If the creation was successful, the response from the `createBucket` function is a `Status` object with the success value. If the creation was unsuccessful, the response is an `error`.

```ballerina
var createBucketResponse = amazonS3Client->createBucket(bucketName);
if (createBucketResponse is amazons3:Status) {
    // If successful, print the status of the operation.
    boolean status = string.create(createBucketResponse.success);
    io:println("Bucket Status: ", status);
} else {
    // If unsuccessful, print the error returned.
    io:println("Error: ", createBucketResponse);
}

```

The `getBucketList` remote function retrives the existing buckets. It returns a `Bucket[]` object if successful or `error` if unsuccessful.

```ballerina
var getBucketListResponse = amazonS3ClientForGetBucketList->getBucketList();
if (getBucketListResponse is amazons3:Bucket[]) {
    io:println("Name of the first bucket: ", getBucketListResponse[0].name);
} else {
    io:println("Error: ", getBucketListResponse);
}
```
## Example
```ballerina
import ballerina/io;
import wso2/amazons3;

amazons3:AmazonS3Configuration amazonS3Config = {
    accessKeyId: "<your_access_key_id>",
    secretAccessKey: "<your_secret_access_key>",
    securityToken: "<your_security_token>",
    region: "<your_region>",
    amazonHost: "<your_host_name>"
};

amazons3:Client amazonS3Client = new(amazonS3Config);

public function main(string... args) {
    string bucketName = "testBallerina";
    io:println("-----------------Calling createBucket() ------------------");
    var createBucketResponse = amazonS3Client->createBucket(bucketName);
    if (createBucketResponse is amazons3:Status) {
        // If successful, print the status of the operation.
        boolean status = createBucketResponse.success;
        io:println("Bucket Status: ", status);
    } else {
        // If unsuccessful, print the error returned.
        io:println("Error: ", createBucketResponse);
    }

    io:println("-----------------Calling getBucketList() ------------------");
    var getBucketListResponse = amazonS3Client->getBucketList();
    if (getBucketListResponse is amazons3:Bucket[]) {
        io:println("Listing all buckets: ");
        foreach var bucket in getBucketListResponse {
            io:println("Bucket Name: ", bucket.name);
        }
    } else {
        io:println("Error: ", getBucketListResponse);
    }

    io:println("-----------------Calling createObject() ------------------");
    var createObjectResponse = amazonS3Client->createObject(bucketName, "test.txt", "Sample content");
    if (createObjectResponse is amazons3:Status) {
        boolean status = createObjectResponse.success;
        io:println("Create object status: ", status);
    } else {
        io:println("Error: ", createObjectResponse);
    }

    io:println("-----------------Calling getObject() ------------------");
    var getObjectResponse = amazonS3Client->getObject(bucketName, "test.txt");
    if (getObjectResponse is amazons3:S3Object) {
        io:println(getObjectResponse);
        string content = getObjectResponse.content;
        io:println("Object content: ", content);
    } else {
        io:println("Error: ", getObjectResponse);
    }

    io:println("-----------------Calling getAllObjects() ------------------");
    var getAllObjectsResponse = amazonS3Client->getAllObjects(bucketName);
    if (getAllObjectsResponse is amazons3:S3Object[]) {
        io:println("Listing all object: ");
        foreach var s3Object in getAllObjectsResponse {
        io:println("---------------------------------");
        io:println("Object Name: ", s3Object.objectName);
        io:println("Object Size: ", s3Object.objectSize);
        }
    } else {
        io:println("Error: ", getAllObjectsResponse);
    }

    io:println("-----------------Calling deleteObject() ------------------");
    var deleteObjectResponse = amazonS3Client->deleteObject(bucketName, "test.txt");
    if (deleteObjectResponse is amazons3:Status) {
        boolean status = deleteObjectResponse.success;
        io:println("Delete object status: ", status);
    } else {
        io:println("Error: ", deleteObjectResponse);
    }

    io:println("-----------------Calling deleteBucket() ------------------");
    var deleteBucketResponse = amazonS3Client->deleteBucket(bucketName);
    if (deleteBucketResponse is amazons3:Status) {
        boolean status = deleteBucketResponse.success;
        io:println("Delete bucket status: ", status);
    } else {
        io:println("Error: ", deleteBucketResponse);
    }
}
```
