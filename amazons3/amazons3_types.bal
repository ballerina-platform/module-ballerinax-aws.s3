//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/http;

# Define the Amazon S3 Connector.
# + accessKeyId - The access key is of the Amazon S3 account
# + secretAccessKey - The secret access key of the Amazon S3 account
# + region - The AWS Region
public type AmazonS3Connector object {
    public string accessKeyId;
    public string secretAccessKey;
    public string region;

    # Retrieve the existing buckets.
    # + return - If success, returns BucketList object, else returns AmazonS3Error object
    public function getBucketList() returns Bucket[]|AmazonS3Error;

    # Create a bucket.
    # + return - If success, returns Status object, else returns AmazonS3Error object
    public function createBucket(string bucketName) returns Status|AmazonS3Error;

    # Retrieve the existing objects in a given bucket.
    # + bucketName - The name of the bucket
    # + return - If success, returns S3Object[] object, else returns AmazonS3Error object
    public function getAllObjects(string bucketName) returns S3Object[]|AmazonS3Error;

    # Retrieves objects from Amazon S3.
    # + bucketName - The name of the bucket
    # + objectName - The name of the object
    # + return - If success, returns S3ObjectContent object, else returns AmazonS3Error object
    public function getObject(string bucketName, string objectName) returns S3Object|AmazonS3Error;

    # Create an object.
    # + objectName - The name of the object
    # + payload - The file that needed to be added to the bucket
    # + return - If success, returns Status object, else returns AmazonS3Error object
    public function createObject(string bucketName, string objectName, string payload) returns Status|AmazonS3Error;

    # Delete an object.
    # + objectName - The name of the object
    # + return - If success, returns Status object, else returns AmazonS3Error object
    public function deleteObject(string bucketName, string objectName) returns Status|AmazonS3Error;

    # Delete a bucket.
    # + return - If success, returns Status object, else returns AmazonS3Error object
    public function deleteBucket(string bucketName) returns Status|AmazonS3Error;
};

# AmazonS3 Client object.
# + amazonS3Config - AmazonS3 Connector configurations
# + amazonS3Connector - AmazonS3 Connector object
public type Client object {

    public AmazonS3Configuration amazonS3Config = {};
    public AmazonS3Connector amazonS3Connector = new;

    # AmazonS3 Connector endpoint initialization function.
    # + config - AmazonS3 Connector Configuration
    public function init(AmazonS3Configuration config);

    # Return the AmazonS3 Connector Client.
    # + return - AmazonS3 Connector Client
    public function getCallerActions() returns AmazonS3Connector;

};

# AmazonS3 Connector configurations can be setup here.
# + accessKeyId - The access key is of the Amazon S3 account
# + secretAccessKey - The secret access key of the Amazon S3 account
# + region - The AWS Region
public type AmazonS3Configuration record {
    string accessKeyId;
    string secretAccessKey;
    string region;
};

# Define the bucket type.
# + name - The name of the bucket
# + creationDate - The creation date of the bucket
public type Bucket record {
    string name;
    string creationDate;
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
    string objectName;
    string lastModified;
    string eTag;
    string objectSize;
    string ownerId;
    string ownerDisplayName;
    string storageClass;
    string content;
};

# Define the status type.
# + success - The status of the AmazonS3 operation
# + statusCode - The status code of the response
public type Status record {
    boolean success;
    int statusCode;
};

# AmazonS3 Client Error.
# + message - Error message of the response
# + cause - The error which caused the AmazonS3 error
# + statusCode - Status code of the response
public type AmazonS3Error record {
    string message;
    error? cause;
    int statusCode;
};
