## Overview
The Amazon S3 connector allows you to access the Amazon S3 REST API using ballerina. This connector has a base connector called `AmazonS3Cient` which exposes the commonly used functions such as create, get and delete buckets and objects. And other functions related to buckets and objects will be exposed through sub connectors(`AmazonS3BucketClient` and `AmazonS3ObjectClient`) for each other categorization.

## API design for AmazonS3Client functions
### Functions

#### Create bucket
The createBucket function creates a new bucket.
 
##### Function signature
 `public remote function createBucket(string bucketName, CannedACL? cannedACL = ()) returns boolean|error;`

##### Parameters

|     Name               |    Type     |  Description   |
|:------------------:|:--------------:|:--------------:|
| bucketName        |   string         |    Unique name for the bucket to create.   |
|cannedACL | CannedACL | The access control list of the new bucket. |

##### Returns
    On success: Boolean value(true).
    On failure: error.
        
#### List buckets

The `listBuckets()` function retrieves a list of all Amazon S3 buckets that the authenticated user of the request owns. 

##### Function signature
 public remote function listBuckets() returns Bucket[]|error;

 ##### Parameters
 This function does not use any parameters.

 ##### Returns
    On success: Array of Bucket record.
    On failure: error.

#### List objects
The listObjects function retrieves a list of all objects in a bucket.

##### Function signature
 public remote function listObjects(string bucketName, string? delimiter = (), string? encodingType = (), int? maxKeys = (), string? prefix = (), string? startAfter = (), boolean? fetchOwner = (), string? continuationToken = ()) returns S3Object[]|error;

 ##### Parameters
 |     Name               |    Type     |  Description   |
|:------------------:|:--------------:|:--------------:|
|bucketName        |   string         |    The name of the bucket.   |
|delimiter | string | A delimiter is a character you use to group keys.|
|encodingType  |   string  |   The encoding method to be applied on the response.|
|maxKeys    |   int |   The maximum number of keys to include in the response. 
|prefix |   string  | The prefix of the objects to be listed. If unspecified, all objects are listed.|
|startAfter|string| Object key from where to begin listing.|
|fetchOwner|boolean| Set to true, to retrieve the owner information in the response. By default the API does not return the Owner information in the response.|
|continuationToken|string|When the response to this API call is truncated (that is, the IsTruncated response element value is true), the response also includes the NextContinuationToken element. To list the next set of objects, you can use the NextContinuationToken element in the next request as the continuation-token.

 ##### Returns
    On success: Array of S3Object record.
    On failure: error.

#### Create object
The createObject fuction uploads an object to S3.

##### Function signature
    public remote function createObject(string bucketName, string objectName, string payload, CannedACL? cannedACL = ()), CreateObjectHeaders? createObjectHeaders = ()) returns boolean|error;

##### Prameters
 |     Name               |    Type     |  Description   |
|:------------------:|:--------------:|:--------------:|
| bucketName        |   string         |    The name of the bucket.   |
| objectName    |   string         |    The name of the object.   |
| payload    |   string  |   The file content that needed to be added to the bucket.|
|cannedACL | CannedACL | The access control list of the new object. |
|createObjectHeaders | CreateObjectHeaders | Optional headers for the create object function.|

##### Returns
    On success: Boolean value(true).
    On failure: error.

#### Get Object
The getObject function retrieves objects from Amazon S3.

##### Function signature
    public remote function getObject(string bucketName, string objectName, GetObjectHeaders? getObjectHeaders = ()) returns S3Object|error;

##### Prameters
 |     Name               |    Type     |  Description   |
|:------------------:|:--------------:|:--------------:|
| bucketName        |   string         |    The name of the bucket.   |
| objectName    |   string         |    The name of the object.   |
|getObjectHeaders | GetObjectHeaders | Optional headers for the get object function.|

##### Returns
    On success: S3Object record.
    On failure: error.

#### Delete Object
The deleteObject function deletes a given  object.

##### Function signature
    public remote function deleteObject(string bucketName, string objectName, string? versionId = ()) returns boolean|error;

##### Parameters
|Name   |   Type    |   Description
|:------:|:---------:|:------------:|
|bucketName |   string  | Name of the bucket.|
|objectName|string  | Name of the object to be deleted.|
|versionId|string|The specific version of the object to delete, if versioning is enabled.|

##### Returns
    On success: Boolean value(true).
    On failure: error.

#### Delete bucket

##### Function signature
    public remote function deleteBucket(string bucketName) returns boolean|error;

##### Parameters
|Name   |   Type    |   Description
|:------:|:---------:|:------------:|
|bucketName |   string  | Name of the bucket.|

##### Returns
    On success: Boolean value(true).
    On failure: error.


### Records

```
public const ACL_PRIVATE = "private";
public const ACL_PUBLIC_READ = "public-read";
public const PUBLIC_READ_WRITE = "public-read-write";
public const AUTHENTICATED_READ = "aws-exec-read";
public const LOG_DELIVERY_WRITE = "authenticated-read";
public const BUCKET_OWNER_READ = "bucket-owner-read";
public const BUCKET_OWNER_FULL_CONTROL = "bucket-owner-full-control";
public type CannedACL ACL_PRIVATE|ACL_PUBLIC_READ|PUBLIC_READ_WRITE|AUTHENTICATED_READ|LOG_DELIVERY_WRITE|BUCKET_OWNER_READ|BUCKET_OWNER_FULL_CONTROL;

# Represents the optional headers specific to  getObject function.
#
# + modifiedSince - Return the object only if it has been modified since the specified time.
# + unModifiedSince - Return the object only if it has not been modified since the specified time.
# + ifMatch - Return the object only if its entity tag (ETag) is the same as the one specified.
# + ifNoneMatch - Return the object only if its entity tag (ETag) is different from the one specified.
# + range - Downloads the specified range bytes of an object. 
public type GetObjectHeaders record {
    string modifiedSince?;
    string unModifiedSince?;
    string ifMatch?;
    string ifNoneMatch?;
    string range?;
};

# Represents the optional headers specific to createObject function.
#
# + cacheControl - Can be used to specify caching behavior along the request/reply chain.
# + contentDisposition - Specifies presentational information for the object. 
# + contentEncoding - Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field. 
# + contentLength - The size of the object, in bytes.
# + contentMD5 - The base64-encoded 128-bit MD5 digest of the message (without the headers).
# + contentType - A standard MIME type describing the format of the contents.
# + expect - When your application uses 100-continue, it does not send the request body until it receives an acknowledgment.The date and time at which the object is no longer able to be cached. 
# + expires - 
public type CreateObjectHeaders record {
    string cacheControl?;
    string contentDisposition?;
    string contentEncoding?;
    string contentLength?;
    string contentMD5?;
    string contentType?;
    string expect?;
    string expires?;
};

# Define the bucket type.
# + name - The name of the bucket
# + creationDate - The creation date of the bucket
public type Bucket record {
    string name = "";
    string creationDate = "";
};

# Define the S3Object type.
# + objectName - The name of the object
# + lastModified - The last modified date of the object
# + eTag - The etag of the object
# + objectSize - The size of the object
# + ownerId - The id of the object owner
# + ownerDisplayName - The display name of the object owner
# + storageClass - The storage class of the object
# + content - The content of the object
public type S3Object record {
    string objectName = "";
    string lastModified = "";
    string eTag = "";
    string objectSize = "";
    string ownerId = "";
    string ownerDisplayName = "";
    string storageClass = "";
    string content = "";
};
```
