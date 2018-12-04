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
import ballerina/io;

# Amazons3 Client object.
# + amazonS3Connector - AmazonS3Connector Connector object
public type Client client object {

    public AmazonS3Connector amazonS3Connector;

    public function __init(AmazonS3Configuration amazonS3Config) {
        self.amazonS3Connector = new(amazonS3Config);
    }

    # Retrieve the existing buckets.
    # + return - If success, returns BucketList object, else returns error
    remote function getBucketList() returns Bucket[]|error {
        return self.amazonS3Connector->getBucketList();
    }

    # Create a bucket.
    # + return - If success, returns Status object, else returns error
    remote function createBucket(string bucketName) returns Status|error {
        return self.amazonS3Connector->createBucket(bucketName);
    }

    # Retrieve the existing objects in a given bucket.
    # + bucketName - The name of the bucket
    # + return - If success, returns S3Object[] object, else returns error
    remote function getAllObjects(string bucketName) returns S3Object[]|error {
        return self.amazonS3Connector->getAllObjects(bucketName);
    }

    # Retrieves objects from Amazon S3.
    # + bucketName - The name of the bucket
    # + objectName - The name of the object
    # + return - If success, returns S3ObjectContent object, else returns error
    remote function getObject(string bucketName, string objectName) returns S3Object|error {
        return self.amazonS3Connector->getObject(bucketName, objectName);
    }

    # Create an object.
    # + objectName - The name of the object
    # + payload - The file that needed to be added to the bucket
    # + return - If success, returns Status object, else returns error
    remote function createObject(string bucketName, string objectName, string payload) returns Status|error {
        return self.amazonS3Connector->createObject(bucketName, objectName, payload);
    }

    # Delete an object.
    # + objectName - The name of the object
    # + return - If success, returns Status object, else returns error
    remote function deleteObject(string bucketName, string objectName) returns Status|error {
        return self.amazonS3Connector->deleteObject(bucketName, objectName);
    }

    # Delete a bucket.
    # + return - If success, returns Status object, else returns error
    remote function deleteBucket(string bucketName) returns Status|error {
        return self.amazonS3Connector->deleteBucket(bucketName);
    }
};

# AmazonS3 Connector configurations can be setup here.
# + accessKeyId - The access key is of the Amazon S3 account
# + secretAccessKey - The secret access key of the Amazon S3 account
# + region - The AWS Region
# + amazonHost - The AWS host
# + clientConfig - HTTP client config
public type AmazonS3Configuration record {
    string accessKeyId = "";
    string secretAccessKey = "";
    string region = "";
    string amazonHost = "";
    http:ClientEndpointConfig clientConfig = {};
};
