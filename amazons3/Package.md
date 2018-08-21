Connects to Amazon S3 from Ballerina. 

# Package Overview

The Amazon S3 connector allows you to access the Amazon S3 REST API through ballerina. The following section provide you the details on connector operations.


**Buckets Operations**

The `wso2/amazons3` package contains operations that work with buckets. You can list the existing buckets, create a bucket,
delete a bucket and list objects in a bucket.

**Objects Operations**

The `wso2/amazons3` package contains operations that create an object, delete an object and retrieve an object.



## Compatibility
|                    |    Version     |  
|:------------------:|:--------------:|
| Ballerina Language |   0.981.0      |
| Amazon S3 API        |   2006-03-01     |


## Sample

First, import the `wso2/amazons3` package into the Ballerina project.

```ballerina
import wso2/amazons3;
```
    
The Amazon S3 connector can be instantiated using the accessKeyId, secretAccessKey, region, 
and bucketName in the Amazon S3 client config.

**Obtaining Access Keys to Run the Sample**

 1. Create an amazon account by visiting <https://aws.amazon.com/s3/>
 2. Obtain the following parameters
   * Access key ID.
   * Secret access key.
   * Desired Server region.


You can now enter the credentials in the Amazon S3 client config:
```ballerina
endpoint amazons3:Client amazonS3Client {
    accessKeyId:"<your_access_key_id>",
    secretAccessKey:"<your_secret_access_key>",
    region:"<your_region>"
};
```

The `createBucket` function creates a bucket.   
If the creation was successful, the response from the `createBucket` function is a `Status` object with the success value. If the creation was unsuccessful, the response is an `AmazonS3Error`. The `match` operation can be used to handle the response if an error occurs.

```ballerina
var createBucketResponse = amazonS3Client -> createBucket(bucketName);
match createBucketResponse {
    amazons3:Status bucketStatus => {
        //If successful, returns the status value as true.
        boolean status = <string> bucketStatus.success;
        io:println("Bucket Status: " + status);
    }
    //Unsuccessful attempts return an AmazonS3 error.
    amazons3:AmazonS3Error e => io:println(e);
}
```

The `getBucketList` function retrives the existing buckets. It returns a `Bucket[]` object if successful or `AmazonS3Error` if unsuccessful.

```ballerina
var getBucketListResponse = amazonS3ClientForGetBucketList -> getBucketList();
match getBucketListResponse {
    amazons3:Bucket[] buckets => {
        io:println("Name of the first bucket: " + buckets[0].name);
    }
    amazons3:AmazonS3Error e => io:println(e);
}
```
## Example
```ballerina
import ballerina/io;
import wso2/amazons3;

function main(string... args) {
    endpoint amazons3:Client amazonS3Client {
        accessKeyId:"<your_access_key_id>",
        secretAccessKey:"<your_secret_access_key>",
        region:"<your_region>"
    };

    string bucketName = "testBallerina";
    io:println("-----------------Calling createBucket() ------------------");
    var createBucketResponse = amazonS3Client -> createBucket(bucketName);
    match createBucketResponse {
        amazons3:Status bucketStatus => {
            boolean status = bucketStatus.success;
            io:println("Create bucket status: " + status);
        }
        amazons3:AmazonS3Error e => io:println(e);
    }

    io:println("-----------------Calling getBucketList() ------------------");
    var getBucketListResponse = amazonS3Client -> getBucketList();
    match getBucketListResponse {
        amazons3:Bucket[] buckets => {
            io:println("Listing all buckets: ");
            foreach bucket in buckets {
                io:println("Bucket Name: " + bucket.name);
            }
        }
        amazons3:AmazonS3Error e => io:println(e);
    }

    io:println("-----------------Calling createObject() ------------------");
    var createObjectResponse = amazonS3Client -> createObject(bucketName, "test.txt","Sample content");
    match createObjectResponse {
        amazons3:Status objectStatus => {
            boolean status = objectStatus.success;
            io:println("Create object status: " + status);
        }
        amazons3:AmazonS3Error e => io:println(e);
    }

   io:println("-----------------Calling getObject() ------------------");
   var getObjectResponse = amazonS3Client->getObject(bucketName, "test.txt");
   match getObjectResponse {
       amazons3:S3Object s3Object => {
           io:println(s3Object);
           string content = s3Object.content;
           io:println("Object content: " + content);
       }
       amazons3:AmazonS3Error e => io:println(e);
   }

    io:println("-----------------Calling getAllObjects() ------------------");
    var getAllObjectsResponse = amazonS3Client -> getAllObjects(bucketName);
    match getAllObjectsResponse {
        amazons3:S3Object[] s3Objects => {
            io:println("Listing all object: ");
            foreach s3Object in s3Objects {
                io:println("---------------------------------");
                io:println("Object Name: " + s3Object.objectName);
                io:println("Object Size: " + s3Object.objectSize);
            }
        }
        amazons3:AmazonS3Error e => io:println(e);
    }

    io:println("-----------------Calling deleteObject() ------------------");
    var deleteObjectResponse = amazonS3Client -> deleteObject(bucketName, "test.txt");
    match deleteObjectResponse {
        amazons3:Status objectStatus => {
            boolean status = objectStatus.success;
            io:println("Delete object status: " + status);
        }
        amazons3:AmazonS3Error e => io:println(e);
    }

    io:println("-----------------Calling deleteBucket() ------------------");
    var deleteBucketResponse = amazonS3Client -> deleteBucket(bucketName);
    match deleteBucketResponse {
        amazons3:Status bucketStatus => {
            boolean status = bucketStatus.success;
            io:println("Delete bucket status: " + status);
        }
        amazons3:AmazonS3Error e => io:println(e);
    }
}
```
