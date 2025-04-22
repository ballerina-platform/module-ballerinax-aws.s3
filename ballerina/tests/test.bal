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
import ballerina/os;
import ballerina/test;

configurable string testBucketName = os:getEnv("BUCKET_NAME");
configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

string fileName = "test.txt";
string fileName2 = "test2.txt";
string content = "Sample content";
string uploadId = "";
CompletedPart[] parts = [];

ConnectionConfig amazonS3Config = {
    accessKeyId,
    secretAccessKey,
    region
};

final Client amazonS3Client = check new (amazonS3Config);

@test:Config {}
function testCreateBucket() returns error? {
    CannedACL cannedACL = ACL_PRIVATE;
    check amazonS3Client->createBucket(testBucketName, cannedACL);
}

@test:Config {
    dependsOn: [testCreateBucket]
}
function testCreateObjectWithMetadata() returns error? {
    map<string> metadata = {
        "Description": "This is a text file",
        "Language": "English"
    };
    _ = check amazonS3Client->createObject(testBucketName, fileName, content, userMetadataHeaders = metadata);

    string url = check amazonS3Client->createPresignedUrl(testBucketName, fileName, RETRIEVE, 3600);
    http:Client httpClient = check new (url);
    // Use Range header as we only need to check headers
    http:Response httpResponse = check httpClient->get(EMPTY_STRING, {"Range": "bytes=0-0"});
    test:assertEquals(httpResponse.getHeader("x-amz-meta-Description"), "This is a text file", "Metadata mismatch");
    test:assertEquals(httpResponse.getHeader("x-amz-meta-Language"), "English", "Metadata mismatch");
}

@test:Config {
    dependsOn: [testCreateBucket]
}
function testListBuckets() returns error? {
    Bucket[] response = check amazonS3Client->listBuckets();
    string bucketName = response[0].name;
    test:assertTrue(bucketName.length() > 0, msg = "Failed to call listBuckets()");
}

@test:Config {
    dependsOn: [testListBuckets]
}
function testCreateObject() returns error? {
    check amazonS3Client->createObject(testBucketName, fileName, content);
}

@test:Config {
    dependsOn: [testGetObject]
}
function testCreatePresignedUrlGet() returns error? {
    string url = check amazonS3Client->createPresignedUrl(testBucketName, fileName, RETRIEVE, 3600);
    http:Client httpClient = check new (url);
    http:Response httpResponse = check httpClient->get(EMPTY_STRING);
    test:assertEquals(httpResponse.statusCode, 200, "Failed to create presigned URL");
}

@test:Config {
    dependsOn: [testGetObject]
}
function testCreatePresignedUrlPut() returns error? {
    string url = check amazonS3Client->createPresignedUrl(testBucketName, fileName, CREATE, 3600);
    http:Client httpClient = check new (url);
    http:Response httpResponse = check httpClient->put(EMPTY_STRING, content);
    test:assertEquals(httpResponse.statusCode, 200, "Failed to create presigned URL");
}

@test:Config {
    dependsOn: [testGetObject]
}
function testCreatePresignedUrlWithInvalidObjectName() returns error? {
    string|error url = amazonS3Client->createPresignedUrl(testBucketName, EMPTY_STRING, RETRIEVE, 3600);
    test:assertTrue(url is error, msg = "Expected an error but got a URL");
    test:assertEquals((<error>url).message(), EMPTY_OBJECT_NAME_ERROR_MSG);
}

@test:Config {
    dependsOn: [testGetObject]
}

function testCreatePresignedUrlWithInvalidBucketName() returns error? {
    string|error url = amazonS3Client->createPresignedUrl(EMPTY_STRING, fileName, RETRIEVE, 3600);
    test:assertTrue(url is error, msg = "Expected an error but got a URL");
    test:assertEquals((<error>url).message(), EMPTY_BUCKET_NAME_ERROR_MSG);
}

@test:Config {
    dependsOn: [testCreateObject]
}
function testGetObject() returns error? {
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
function testListObjects() returns error? {
    S3Object[] response = check amazonS3Client->listObjects(testBucketName, fetchOwner = true);
    test:assertTrue(response.length() > 0, msg = "Failed to call listObjects()");
}

@test:Config {
    dependsOn: [testListObjects]
}
function testDeleteObject() returns error? {
    check amazonS3Client->deleteObject(testBucketName, fileName);
}

@test:Config {
    dependsOn: [testListObjects]
}
function testCreateMultipartUpload() returns error? {
    uploadId = check amazonS3Client->createMultipartUpload(fileName2, testBucketName);
    test:assertTrue(uploadId.length() > 0, "Failed to create multipart upload");
}

@test:Config {
    dependsOn: [testCreateMultipartUpload]
}
function testUploadPart() returns error? {
    CompletedPart response = check amazonS3Client->uploadPart(fileName2, testBucketName, content, uploadId, 1);
    parts.push(response);
    test:assertTrue(response.ETag.length() > 0, msg = "Failed to upload part");
}

@test:Config {
    dependsOn: [testUploadPart]
}
function testCompleteMultipartUpload() returns error? {
    check amazonS3Client->completeMultipartUpload(fileName2, testBucketName, uploadId, parts);
}

@test:Config {
    dependsOn: [testCompleteMultipartUpload]
}
function testDeleteMultipartUpload() returns error? {
    check amazonS3Client->deleteObject(testBucketName, fileName2);
}

@test:Config {
    dependsOn: [testListBuckets],
    before: testCreateMultipartUpload
}
function testAbortFileUpload() returns error? {
    check amazonS3Client->abortMultipartUpload(fileName2, testBucketName, uploadId);
}

@test:AfterSuite {}
function testDeleteBucket() returns error? {
    check amazonS3Client->deleteBucket(testBucketName);
}
