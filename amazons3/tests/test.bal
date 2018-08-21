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

import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/test;

string testAccessKeyId = config:getAsString("ACCESS_KEY_ID");
string testSecretAccessKey = config:getAsString("SECRET_ACCESS_KEY");
string testRegion = config:getAsString("REGION");
string testBucketName = config:getAsString("BUCKET_NAME");

endpoint Client amazonS3Client {
    accessKeyId: testAccessKeyId,
    secretAccessKey: testSecretAccessKey,
    region: testRegion
};

@test:Config
function testGetBucketList() {
    log:printInfo("amazonS3ClientForGetBucketList -> getBucketList()");
    var rs = amazonS3Client -> getBucketList();
    match rs {
        Bucket [] buckets => {
            string bucketName = buckets[0].name;
            test:assertTrue(bucketName.length() > 0, msg = "Failed to call getBucketList()");
        }
        AmazonS3Error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config {
    dependsOn: ["testGetBucketList"]
}
function testCreateBucket() {
    log:printInfo("amazonS3Client -> createBucket()");
    var rs = amazonS3Client -> createBucket(testBucketName);
    match rs {
        Status status => {
            boolean bucketStatus = status.success;
            test:assertTrue(bucketStatus, msg = "Failed createBucket()");
        }
        AmazonS3Error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config {
    dependsOn: ["testCreateBucket"]
}
function testCreateObject() {
    log:printInfo("amazonS3Client -> createObject()");
    var rs = amazonS3Client -> createObject(testBucketName, "test.txt","Sample content");
    match rs {
        Status staus => {
            boolean objectStatus = staus.success;
            test:assertTrue(objectStatus, msg = "Failed createObject()");
        }
        AmazonS3Error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config {
    dependsOn: ["testCreateObject"]
}
function testGetObject() {
    log:printInfo("amazonS3Client -> getObject()");
    var rs = amazonS3Client->getObject(testBucketName, "test.txt");
    match rs {
        S3Object s3Object => {
            string content = s3Object.content;
            test:assertTrue(content.length() > 0, msg = "Failed to call getObject()");

        }
        AmazonS3Error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config {
    dependsOn: ["testGetObject"]
}
function testGetAllObjects() {
    log:printInfo("amazonS3Client -> getAllObjects()");
    var rs = amazonS3Client -> getAllObjects(testBucketName);
    match rs {
        S3Object[] s3Object => {
            test:assertTrue(lengthof s3Object > 0, msg = "Failed to call getAllObjects()");
        }
        AmazonS3Error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config {
    dependsOn: ["testGetAllObjects"]
}
function testDeleteObject() {
    log:printInfo("amazonS3Client -> deleteObject()");
    var rs = amazonS3Client -> deleteObject(testBucketName, "test.txt");
    match rs {
        Status staus => {
            boolean objectStatus = staus.success;
            test:assertTrue(objectStatus, msg = "Failed deleteObject()");
        }
        AmazonS3Error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config {
    dependsOn: ["testDeleteObject"]
}
function testDeleteBucket() {
    log:printInfo("amazonS3Client -> deleteBucket()");
    var rs = amazonS3Client -> deleteBucket(testBucketName);
    match rs {
        Status staus => {
            boolean bucketStatus = staus.success;
            test:assertTrue(bucketStatus, msg = "Failed deleteBucket()");
        }
        AmazonS3Error err => {
            test:assertFail(msg = err.message);
        }
    }
}
