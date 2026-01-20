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

    // Example 1: Stream upload (putObjectAsStream)
    string objectKey1 = "stream-upload.txt";
    io:println("\n1. Uploading object via stream...");

    byte[] data = "Hello from streaming upload!".toBytes();
    stream<byte[], error?> uploadStream = [data].toStream();

    check s3Client->putObjectAsStream(bucketName, objectKey1, uploadStream);
    io:println("Object uploaded via stream: " + objectKey1);

    // Example 2: Stream download (getObjectAsStream)
    io:println("\n2. Downloading object via stream...");

    stream<byte[], error?> downloadStream = check s3Client->getObjectAsStream(bucketName, objectKey1);
    int totalBytes = 0;

    check from byte[] chunk in downloadStream
        do {
            totalBytes += chunk.length();
        };

    io:println("Downloaded " + totalBytes.toString() + " bytes via stream.");

    // Example 3: Stream multipart upload (uploadPartAsStream)
    io:println("\n3. Multipart upload with streaming...");

    string objectKey2 = "multipart-stream.bin";
    string uploadId = check s3Client->createMultipartUpload(bucketName, objectKey2);
    io:println("Multipart upload created. Upload ID: " + uploadId);

    string[] etags = [];
    int[] partNumbers = [];

    // Upload Part 1 via stream (5MB)
    byte[] part1Data = createData(5 * 1024 * 1024);
    stream<byte[], error?> part1Stream = [part1Data].toStream();
    string etag1 = check s3Client->uploadPartAsStream(bucketName, objectKey2, uploadId, 1, part1Stream, 
        contentLength = part1Data.length()
    );
    etags.push(etag1);
    partNumbers.push(1);
    io:println("Part 1 uploaded via stream (5MB). ETag: " + etag1);

    // Upload Part 2 via stream (1MB - last part)
    byte[] part2Data = createData(1 * 1024 * 1024);
    stream<byte[], error?> part2Stream = [part2Data].toStream();
    string etag2 = check s3Client->uploadPartAsStream(bucketName, objectKey2, uploadId, 2, part2Stream, 
        contentLength = part2Data.length()
    );
    etags.push(etag2);
    partNumbers.push(2);
    io:println("Part 2 uploaded via stream (1MB). ETag: " + etag2);

    // Complete multipart upload
    check s3Client->completeMultipartUpload(bucketName, objectKey2, uploadId, partNumbers, etags);
    io:println("Multipart upload completed via streaming!");

    // Clean up
    check s3Client->deleteObject(bucketName, objectKey1);
    check s3Client->deleteObject(bucketName, objectKey2);
    check s3Client->deleteBucket(bucketName);
    io:println("\nCleanup completed.");
}

// Helper function to create test data
function createData(int size) returns byte[] {
    byte[] data = [];
    foreach int i in 0 ..< size {
        data.push(<byte>(i % 256));
    }
    return data;
}