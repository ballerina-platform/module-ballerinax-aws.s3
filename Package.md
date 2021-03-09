Connects to Amazon S3 from Ballerina. 

# Module Overview

The Amazon S3 client allows you to access Amazon S3 REST API through Ballerina. The following section provide you the 
details on connector operations.

**Buckets Operations**

The `ballerinax/aws.s3` module contains operations that work with buckets. You can list the existing buckets, create a bucket, 
delete a bucket, and list objects in a bucket.

**Objects Operations**

The `ballerinax/aws.s3` module contains operations that create an object, delete an object, and retrieve an object.

## Compatibility
|                    |    Version                  |  
|:------------------:|:---------------------------:|
| Ballerina Language |   Swan Lake Alpha2          |
|   Amazon S3 API    |   2006-03-01                |

## Running Sample

Let's get started with a simple program in Ballerina to create a new bucket.

Use the following command to search for modules where the module name, description, or org name contains the word "aws.s3".

```ballerina
$ bal search aws.s3
```

This results in a list of available modules. You can pull the one you want from Ballerina Central.

```ballerina
$ bal pull ballerinax/aws.s3
```

You can use the `ballerinax/aws.s3` module to integrate with Amazon S3 back-end. Import the `ballerinax/aws.s3` module into the Ballerina project.

Now you can use Ballerina to integrate with Amazon S3.

#### Before you Begin

You need to get credentials such as **Access Key** and **Secret Access Key (API Secret)** from Amazon S3.

**Obtaining Access Keys**

 1. Create an Amazon account by visiting <https://aws.amazon.com/s3/>
 2. Create a new access key, which includes a new secret access key.
    - To create a new secret access key for your root account, use the [security credentials](https://console.aws.amazon.com/iam/home?#security_credential) page. Expand the Access Keys section, and then click **Create New Root Key**.
    - To create a new secret access key for an IAM user, open the [IAM console](https://console.aws.amazon.com/iam/home?region=us-east-1#home). Click **Users** in the **Details** pane, click the appropriate IAM user, and then click **Create Access Key** on the **Security Credentials** tab.
3. Download the newly created credentials, when prompted to do so in the key creation wizard.

In the directory where you have your sample, create a `Config.toml` file and add the details you obtained above within the quotes. region, trustStorePath and trustStorePassword are optionals.

**Ballerina Config.toml file**

```
accessKeyId = ""
secretAccessKey = ""
region = ""
trustStorePath = ""
trustStorePassword = ""
```

## Samples

#### Create a new Bucket

```ballerina
import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() {
    s3:CannedACL cannedACL = s3:ACL_PRIVATE;
    s3:ConnectorError? createBucketResponse = amazonS3Client->createBucket(bucketName, cannedACL);
    if (createBucketResponse is s3:ConnectorError) {
        io:println("Error: ", createBucketResponse.message());
    } else {
        io:println("Bucket Creation Status: Success");
    }
}
```
#### List Buckets

```ballerina
import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() {
    var listBucketResponse = amazonS3Client->listBuckets();
    if (listBucketResponse is s3:Bucket[]) {
        io:println("Listing all buckets: ");
        foreach var bucket in listBucketResponse {
            io:println("Bucket Name: ", bucket.name);
        }
    } else {
        io:println("Error: ", listBucketResponse);
    }
}
```
#### Create a new Object

```ballerina
import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() {
    s3:ConnectorError? createObjectResponse = amazonS3Client->createObject(bucketName, "test.txt", "Sample content");
    if (createObjectResponse is s3:ConnectorError) {
        io:println("Error: ", createObjectResponse.message());
    } else {
        io:println("Object created successfully");
    }
}
```

#### List Objects

```ballerina
import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() returns error? {
    var listObjectsResponse = amazonS3Client->listObjects(bucketName);
    if (listObjectsResponse is s3:S3Object[]) {
        io:println("Listing all object: ");
        foreach var s3Object in listObjectsResponse {
            io:println("---------------------------------");
            io:println("Object Name: ", s3Object["objectName"]);
            io:println("Object Size: ", s3Object["objectSize"]);
        }
    } else {
        io:println("Error: ", listObjectsResponse);
    }
}
```
#### Get an Object

```ballerina
import ballerina/io;
import ballerina/lang.'string as strings;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() returns error? {
    var getObjectResponse = amazonS3Client->getObject(bucketName, "test.txt");
    if (getObjectResponse is s3:S3Object) {
        io:println(getObjectResponse);
        byte[]? byteArray = getObjectResponse["content"];
        if (byteArray is byte[]) {
            string content = check strings:fromBytes(byteArray);
            io:println("Object content: ", content);
        }
    } else {
        io:println("Error: ", getObjectResponse);
    }
}
```
#### Delete an Object

```ballerina
import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new(amazonS3Config);

public function main() {
    s3:ConnectorError? deleteObjectResponse = amazonS3Client->deleteObject(bucketName, "test.txt");
    if (deleteObjectResponse is s3:ConnectorError) {
        io:println("Error: ", deleteObjectResponse.message());
    } else {
        io:println("Successfully deleted object");
    }
}
```

#### Delete a Bucket

```ballerina
import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() {
    s3:ConnectorError? deleteBucketResponse = amazonS3Client->deleteBucket(bucketName);
    if (deleteBucketResponse is s3:ConnectorError) {
        io:println("Error: ", deleteBucketResponse.message());
    } else {
        io:println("Successfully deleted bucket");
    }
}
```
