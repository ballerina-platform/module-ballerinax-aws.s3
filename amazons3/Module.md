Connects to Amazon S3 from Ballerina. 

# Module Overview

The Amazon S3 client allows you to access the Amazon S3 REST API through ballerina. The following section provide you the details on connector operations.


**Buckets Operations**

The `wso2/amazons3` module contains operations that work with buckets. You can list the existing buckets, create a bucket,
delete a bucket and list objects in a bucket.

**Objects Operations**

The `wso2/amazons3` module contains operations that create an object, delete an object and retrieve an object.

## Compatibility
|                    |    Version     |  
|:------------------:|:--------------:|
| Amazon S3 API      |   2006-03-01   |

## Running Sample

Let's get started with a simple program in Ballerina to create a new bucket.

Use the following command to search for modules where the module name, description, or org name contains the word "amazons3".

```ballerina
$ ballerina search amazons3
```

This results in a list of available modules. You can pull the one you want from Ballerina Central.

```ballerina
$ ballerina pull wso2/amazons3
```

You can use the `wso2/amazons3` module to integrate with Amazon S3 back-end. Import the `wso2/amazons3` module into the Ballerina project.

Now you can use Ballerina to integrate with Amazon S3.

#### Before you Begin

You need to get credentials such as Access Key, Secret Access Key (API Secret) from Amazon S3.

**Obtaining Access Keys**

 1. Create an amazon account by visiting <https://aws.amazon.com/s3/>
 2. Create a new access key, which includes a new secret access key.
    - To create a new secret access key for your root account, use the [security credentials](https://console.aws.amazon.com/iam/home?#security_credential) page. Expand the Access Keys section, and then click Create New Root Key.
    - To create a new secret access key for an IAM user, open the [IAM console](https://console.aws.amazon.com/iam/home?region=us-east-1#home). Click Users in the Details pane, click the appropriate IAM user, and then click Create Access Key on the Security Credentials tab.
3. Download the newly created credentials, when prompted to do so in the key creation wizard.

In the directory where you have your sample, create a `ballerina.conf` file and add the details you obtained above within the quotes.

# Ballerina config file
accessKey = ""
secretAccessKey = ""
```

#### Ballerina Program to Create a new Bucket
Create a file called `amazonS3_sample.bal` and import the `ballerina/config` module.

```ballerina
import ballerina/config;
```

Add this code after the import statement to create base/parent Amazon S3 client.

```ballerina
amazons3:AmazonS3Configuration amazonS3Config = {
    accessKeyId: config:getAsString("accessKey"),
    secretAccessKey: config:getAsString("secretAccessKey")
};

amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
```
Here, we are creating a client object with the above configuration to connect with the Amazon S3 service.

Now you can create a new bucket in Amzon S3 by invoking the `createBucket` remote function.

```ballerina
string bucketName = "testBucket";
// Invoke createBucket remote function using base/parent Amazon S3 client.
amazons3:Status|error createBucketResponse = amazonS3Client->createBucket(bucketName);
```

If the creation was successful, the response from the `createBucket` function is a `Status` object with the success value. If the creation was unsuccessful, the response is an `error`.

The complete source code look similar to the following:
```ballerina
import wso2/amazons3;

import ballerina/config;
import ballerina/io;

 // Create the AmazonS3Configuration that can be used to connect with the Amazon S3 service..
amazons3:AmazonS3Configuration amazonS3Config = {
    accessKeyId: config:getAsString("accessKey"),
    secretAccessKey: config:getAsString("secretAccessKey")
};

public function main() {
    // Create the AmazonS3 client with amazonS3Config. 
    amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is AmazonS3Client) {
        string bucketName = "testBucket";
        amazons3:CannedACL cannedACL = amazons3:ACL_PRIVATE;
        // Invoke createBucket remote function using base/parent Amazon S3 client.
        amazons3:Status|error createBucketResponse = amazonS3Client->createBucket(bucketName, cannedACL = cannedACL);
        if (createBucketResponse is amazons3:Status) {
            // If successful, print the status of the operation.
            boolean status = string.create(createBucketResponse.success);
            io:println("Bucket Creation Status: ", status);
        } else {
            // If unsuccessful, print the error returned.
            io:println("Error: ", createBucketResponse);
        }
    }
}
```
Now you can run the sample using the following command:
```ballerina
$ ballerina run amazons3_sample.bal --config ballerina.conf
```

## Sample
```ballerina
import ballerina/io;

import wso2/amazons3;

amazons3:AmazonS3Configuration amazonS3Config = {
    accessKeyId: "<your_access_key_id>",
    secretAccessKey: "<your_secret_access_key>"
};

public function main(string... args) {
    amazons3:AmazonS3Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is amazons3:AmazonS3Client) {
        string bucketName = "testBallerina";
        io:println("-----------------Calling createBucket() ------------------");
        CannedACL cannedACL = ACL_PRIVATE;
        var createBucketResponse = amazonS3Client->createBucket(bucketName, cannedACL = cannedACL);
        if (createBucketResponse is amazons3:Status) {
            // If successful, print the status of the operation.
            boolean status = createBucketResponse.success;
            io:println("Bucket Status: ", status);
        } else {
            // If unsuccessful, print the error returned.
            io:println("Error: ", createBucketResponse);
        }

        io:println("-----------------Calling listBuckets() ------------------");
        var listBucketResponse = amazonS3Client->listBuckets();
        if (listBucketResponse is amazons3:Bucket[]) {
            io:println("Listing all buckets: ");
            foreach var bucket in listBucketResponse {
                io:println("Bucket Name: ", bucket.name);
            }
        } else {
            io:println("Error: ", listBucketResponse);
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

        io:println("-----------------Calling listObjects() ------------------");
        var listObjectsResponse = amazonS3Client->listObjects(bucketName);
        if (listObjectsResponse is amazons3:S3Object[]) {
            io:println("Listing all object: ");
            foreach var s3Object in listObjectsResponse {
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
    } else {
        io:println("Error: ", amazonS3Client);
    }
}
```
