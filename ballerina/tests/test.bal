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

import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/os;
import ballerina/test;

configurable string testBucketName = os:getEnv("BUCKET_NAME");
configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");
string fileName = "test.txt";
string fileName2 = "test2.txt";
string content = "Sample content";
string uploadId_= "";
CompletedPart[] parts = [];

ConnectionConfig amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

@test:Config{}
function testCreateBucket() {
    log:printInfo("amazonS3Client->createBucket()");
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
    log:printInfo("amazonS3Client->listBuckets()");
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
    log:printInfo("amazonS3Client->createObject()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        error? response = amazonS3Client->createObject(testBucketName, fileName, content);
        if (response is error) {
            test:assertFail(response.toString());
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testGetObject]
}
function testCreatePresignedUrlGet() returns error? {
    log:printInfo("amazonS3Client->createPresignedUrl() RETRIEVE");
    Client amazonS3Client = check new (amazonS3Config);
    string url = check amazonS3Client->createPresignedUrl(testBucketName, fileName, RETRIEVE, 3600);
    http:Client httpClient = check new (url);
    http:Response httpResponse = check httpClient->get(EMPTY_STRING);
    test:assertEquals(httpResponse.statusCode, 200, "Failed to create presigned URL");
}

@test:Config {
    dependsOn: [testGetObject]
}
function testCreatePresignedUrlPut() returns error? {
    log:printInfo("amazonS3Client->createPresignedUrl() CREATE");
    Client amazonS3Client = check new (amazonS3Config);
    string url = check amazonS3Client->createPresignedUrl(testBucketName, fileName, CREATE, 3600);
    http:Client httpClient = check new (url);
    http:Response httpResponse = check httpClient->put(EMPTY_STRING, content);
    test:assertEquals(httpResponse.statusCode, 200, "Failed to create presigned URL");
}

@test:Config {
    dependsOn: [testGetObject]
}
function testCreatePresignedUrlWithInvalidObjectName() returns error? {
    log:printInfo("amazonS3Client->createPresignedUrl() with invalid object name");
    Client amazonS3Client = check new (amazonS3Config);
    string|error url = amazonS3Client->createPresignedUrl(testBucketName, EMPTY_STRING, RETRIEVE, 3600);
    test:assertTrue(url is error, msg = "Expected an error but got a URL");
    test:assertEquals((<error>url).message(), EMPTY_OBJECT_NAME_ERROR_MSG);
}

@test:Config {
    dependsOn: [testGetObject]
}

function testCreatePresignedUrlWithInvalidBucketName() returns error? {
    log:printInfo("amazonS3Client->createPresignedUrl() with invalid bucket name");
    Client amazonS3Client = check new (amazonS3Config);
    string|error url = amazonS3Client->createPresignedUrl(EMPTY_STRING, fileName, RETRIEVE, 3600);
    test:assertTrue(url is error, msg = "Expected an error but got a URL");
    test:assertEquals((<error>url).message(), EMPTY_BUCKET_NAME_ERROR_MSG);
}

@test:Config {
    dependsOn: [testCreateBucket]
}
function testCreateObjectWithMetadata() returns error? {
    map<string> metadata = {
        "Description" : "This is a text file",
        "Language" : "English"
    };
    
    Client amazonS3Client = check new(amazonS3Config);
    _ = check amazonS3Client->createObject(testBucketName, fileName, content, userMetadataHeaders = metadata);
}

@test:Config {
    dependsOn: [testCreateObject]
}
function testGetObject() returns error? {
    log:printInfo("amazonS3Client->getObject()");
    Client amazonS3Client = check new (amazonS3Config);
    stream<byte[], io:Error?> response = check amazonS3Client->getObject(testBucketName, fileName);
    record {|byte[] value;|}? chunk = check response.next();
    if chunk is record {|byte[] value;|} {
        string resContent = check string:fromBytes(chunk.value);
        test:assertEquals(content, resContent, "Content mismatch");
    }
}

@test:Config {
    dependsOn: [testGetObject]
}
function testListObjects() {
    log:printInfo("amazonS3Client->listObjects()");
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
    log:printInfo("amazonS3Client->deleteObject()");
    Client|error amazonS3Client = new(amazonS3Config);
    if (amazonS3Client is Client) {
        error? response = amazonS3Client -> deleteObject(testBucketName, fileName);
        if (response is error) {
            test:assertFail(response.toString());
        }
    } else {
        test:assertFail(amazonS3Client.toString());
    }
}

@test:Config {
    dependsOn: [testListObjects]
}
function testCreateMultipartUpload() returns error? {
    log:printInfo("amazonS3Client->createMultipartUpload()");
    Client amazonS3Client = check new (amazonS3Config);
    string|error uploadId = amazonS3Client->createMultipartUpload(fileName2, testBucketName);
    if uploadId is error {
        test:assertFail(uploadId.toString());
    } else {
        uploadId_ = uploadId;
        test:assertTrue(uploadId.length() > 0, msg = "Failed to create multipart upload");
    }
}

@test:Config {
    dependsOn: [testCreateMultipartUpload]
}
function testUploadPart() returns error? {
    log:printInfo("amazonS3Client->uploadPart()");
    Client amazonS3Client =check new (amazonS3Config);
    CompletedPart|error response = amazonS3Client->UploadPart(fileName2, testBucketName, content, uploadId_, 1);
    if (response is CompletedPart) {
        parts.push(response);
        test:assertTrue(response.ETag.length() > 0, msg = "Failed to upload part");
    } else {
        test:assertFail(response.toString());
    }
}

@test:AfterSuite {}
function testDeleteBucket() {
    log:printInfo("amazonS3Client->deleteBucket()");
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
