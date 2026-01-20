// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerinax/aws.s3;

configurable string bucketName = ?;
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

public function main() returns error? {
    s3:Client s3Client = check new ({
        region: "us-east-1",
        auth: {
            accessKeyId,
            secretAccessKey
        }
    });

    check s3Client->createBucket(bucketName);
    io:println("Bucket created: " + bucketName);

    string objectKey = "large-file.bin";

    // Create multipart upload
    string uploadId = check s3Client->createMultipartUpload(bucketName, objectKey);
    io:println("Multipart upload created. Upload ID: " + uploadId);

    // Upload parts (minimum 5MB each except last part)
    string[] etags = [];
    int[] partNumbers = [];

    // Part 1: 5MB
    io:println("Uploading Part 1 (5MB)...");
    byte[] part1 = createData(5 * 1024 * 1024);
    string etag1 = check s3Client->uploadPart(bucketName, objectKey, uploadId, 1, part1);
    etags.push(etag1);
    partNumbers.push(1);
    io:println("Part 1 uploaded. ETag: " + etag1);

    // Part 2: 5MB
    io:println("Uploading Part 2 (5MB)...");
    byte[] part2 = createData(5 * 1024 * 1024);
    string etag2 = check s3Client->uploadPart(bucketName, objectKey, uploadId, 2, part2);
    etags.push(etag2);
    partNumbers.push(2);
    io:println("Part 2 uploaded. ETag: " + etag2);

    // Part 3: 1MB (last part can be smaller)
    io:println("Uploading Part 3 (1MB - last part)...");
    byte[] part3 = createData(1 * 1024 * 1024);
    string etag3 = check s3Client->uploadPart(bucketName, objectKey, uploadId, 3, part3);
    etags.push(etag3);
    partNumbers.push(3);
    io:println("Part 3 uploaded. ETag: " + etag3);

    // Complete multipart upload
    check s3Client->completeMultipartUpload(bucketName, objectKey, uploadId, partNumbers, etags);
    io:println("Multipart upload completed successfully!");
    io:println("Total file size: 11 MB");

    // Clean up
    check s3Client->deleteObject(bucketName, objectKey);
    check s3Client->deleteBucket(bucketName);
    io:println("Cleanup completed.");
}

// Helper function to create test data
function createData(int size) returns byte[] {
    byte[] data = [];
    foreach int i in 0 ..< size {
        data.push(<byte>(i % 256));
    }
    return data;
}