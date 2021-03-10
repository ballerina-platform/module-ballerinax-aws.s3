//
// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/log;
import ballerina/test;
import ballerina/os;

configurable string testBucketName = os:getEnv("BUCKET_NAME");
configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

@test:Config{}
function testCreateBucket() {
    log:print("amazonS3Client->createBucket()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        CannedACL cannedACL = ACL_PRIVATE;
        error? response = amazonS3Client->createBucket(testBucketName, cannedACL);
        if (response is error) {
            test:assertFail(response.toString());
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testCreateBucket]
}
function testListBuckets() {
    log:print("amazonS3Client->listBuckets()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        Bucket[]|error response =  amazonS3Client->listBuckets();
        if (response is error) {
            test:assertFail(response.toString());
        } else {
            string bucketName = response[0].name;
            test:assertTrue(bucketName.length() > 0, msg = "Failed to call listBuckets()");
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testListBuckets]
}
function testCreateObject() {
    log:print("amazonS3Client->createObject()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        error? response = amazonS3Client->createObject(testBucketName, "test.txt", "Sample content");
        if (response is error) {
            test:assertFail(response.toString());
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testCreateObject]
}
function testGetObject() {
    log:print("amazonS3Client->getObject()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        S3Object|error response = amazonS3Client->getObject(testBucketName, "test.txt");
        if (response is S3Object) {
            byte[]? content = response["content"];
        } else {
            test:assertFail(response.toString());
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testGetObject]
}
function testListObjects() {
    log:print("amazonS3Client->listObjects()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        S3Object[]|error response = amazonS3Client -> listObjects(testBucketName, fetchOwner = true);
        if (response is error) {
            test:assertFail(response.toString());
        } else {
            test:assertTrue(response.length() > 0, msg = "Failed to call listObjects()");
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testListObjects]
}
function testDeleteObject() {
    log:print("amazonS3Client -> deleteObject()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        error? response = amazonS3Client -> deleteObject(testBucketName, "test.txt");
        if (response is error) {
            test:assertFail(response.toString());
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testDeleteObject]
}
function testDeleteBucket() {
    log:print("amazonS3Client -> deleteBucket()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        error? response = amazonS3Client -> deleteBucket(testBucketName);
        if (response is error) {
            test:assertFail(response.toString());
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}
