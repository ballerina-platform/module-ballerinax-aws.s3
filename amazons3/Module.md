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
| Ballerina Language |   0.990.0      |
| Amazon S3 API        |   2006-03-01     |


## Sample

First, import the `wso2/amazons3` module into the Ballerina project.

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
amazons3:AmazonS3Configuration amazonS3Config = {
        accessKeyId:"",
        secretAccessKey:"",
        region:""
};
amazons3:Client amazonS3Client = new(amazonS3Config);

```

The `createBucket` function creates a bucket.   
If the creation was successful, the response from the `createBucket` function is a `Status` object with the success value. If the creation was unsuccessful, the response is an `error`. 

```ballerina
var createBucketResponse = amazonS3Client -> createBucket(bucketName);
if (createBucketResponse is amazons3:Status) {
    //If successful, returns the status value as true.
    boolean status = string.create(createBucketResponse.success);
    io:println("Bucket Status: " + status);
} else {
    //Unsuccessful attempts return an AmazonS3 error.
    io:println(createBucketResponse);
}

```

The `getBucketList` function retrives the existing buckets. It returns a `Bucket[]` object if successful or `error` if unsuccessful.

```ballerina
var getBucketListResponse = amazonS3ClientForGetBucketList -> getBucketList();
if (getBucketListResponse is amazons3:Bucket[]) {
    io:println("Name of the first bucket: " + getBucketListResponse[0].name);
} else {
    io:println(getBucketListResponse);
}
```
## Example
```ballerina
import ballerina/io;
import wso2/amazons3;

amazons3:AmazonS3Configuration amazonS3Config = {
        accessKeyId:"<your_access_key_id>",
        secretAccessKey:"<your_secret_access_key>",
        region:"<your_region>"
};

amazons3:Client amazonS3Client = new(amazonS3Config);

function main(string... args) {

    string bucketName = "testBallerina";
    io:println("-----------------Calling createBucket() ------------------");
    if (createBucketResponse is amazons3:Status) {
        //If successful, returns the status value as true.
        boolean status = string.create(createBucketResponse.success);
        io:println("Bucket Status: " + status);
    } else {
        //Unsuccessful attempts return an AmazonS3 error.
        io:println(createBucketResponse);
    }

    io:println("-----------------Calling getBucketList() ------------------");
    var getBucketListResponse = amazonS3Client -> getBucketList();
    if (getBucketListResponse is amazons3:Bucket[]) {
        io:println("Listing all buckets: ");
        foreach bucket in getBucketListResponse {
           io:println("Bucket Name: " + bucket.name);
        }
    } else {
        io:println(getBucketListResponse);
    }

    io:println("-----------------Calling createObject() ------------------");
    var createObjectResponse = amazonS3Client -> createObject(bucketName, "test.txt","Sample content");
    if (createObjectResponse is amazons3:Status) {
        boolean status = createObjectResponse.success;
        io:println("Create object status: " + status);
    } else {
        io:println(createObjectResponse);
    }

   io:println("-----------------Calling getObject() ------------------");
   var getObjectResponse = amazonS3Client->getObject(bucketName, "test.txt");
   if (getObjectResponse is amazons3:S3Object) {
       io:println(getObjectResponse);
       string content = getObjectResponse.content;
       io:println("Object content: " + content);
   } else {
       io:println(getObjectResponse);
   }

    io:println("-----------------Calling getAllObjects() ------------------");
    var getAllObjectsResponse = amazonS3Client -> getAllObjects(bucketName);
    if (getAllObjectsResponse is amazons3:S3Object[]) {
        io:println("Listing all object: ");
        foreach s3Object in getAllObjectsResponse {
            io:println("---------------------------------");
            io:println("Object Name: " + s3Object.objectName);
            io:println("Object Size: " + s3Object.objectSize);
        }
    } else {
        io:println(getAllObjectsResponse);
    }

    io:println("-----------------Calling deleteObject() ------------------");
    var deleteObjectResponse = amazonS3Client -> deleteObject(bucketName, "test.txt");
    if (deleteObjectResponse is amazons3:Status) {
        boolean status = deleteObjectResponse.success;
        io:println("Delete object status: " + status);
    } else {
        io:println(deleteObjectResponse);
    }

    io:println("-----------------Calling deleteBucket() ------------------");
    var deleteBucketResponse = amazonS3Client -> deleteBucket(bucketName);
    if (deleteBucketResponse is amazons3:Status) {
        boolean status = deleteBucketResponse.success;
        io:println("Delete bucket status: " + status);
    } else {
        io:println(deleteBucketResponse);
    }
}
```
