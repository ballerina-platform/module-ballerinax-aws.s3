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

    do {
        check s3Client->createBucket(bucketName);
        io:println("Bucket created: " + bucketName);

        // 1. Upload String content
        string textContent = "Hello from Ballerina S3 Connector!";
        check s3Client->putObject(bucketName, "sample.txt", textContent);
        io:println("String object uploaded: sample.txt");

        // 2. Upload Byte array
        byte[] binaryData = [72, 101, 108, 108, 111];
        check s3Client->putObject(bucketName, "binary.bin", binaryData);
        io:println("Binary object uploaded: binary.bin");

        // 3. Retrieve String content
        string retrievedText = check s3Client->getObjectAsText(bucketName, "sample.txt");
        io:println("Retrieved text: " + retrievedText);

        // 4. Get object metadata
        s3:ObjectMetadata metadata = check s3Client->getObjectMetadata(bucketName, "sample.txt");
        io:println("Object metadata - Size: " + metadata.contentLength.toString() + " bytes");

        // 5. Copy object
        check s3Client->copyObject(bucketName, "sample.txt", bucketName, "sample-copy.txt");
        io:println("Object copied: sample.txt -> sample-copy.txt");

        // 6. List objects in bucket
        _ = check s3Client->listObjects(bucketName);
        io:println("Objects listed successfully.");

        // 7. Delete objects
        check s3Client->deleteObject(bucketName, "sample.txt");
        _ = check s3Client->deleteObject(bucketName, "binary.bin");
        _ = check s3Client->deleteObject(bucketName, "sample-copy.txt");
        io:println("All objects deleted.");

        check s3Client->deleteBucket(bucketName);
        io:println("Bucket deleted: " + bucketName);

    } on fail error e {
        // Best-effort cleanup: delete objects and bucket, log warnings on failure
        error? delErr = s3Client->deleteObject(bucketName, "sample.txt");
        if delErr is error {
            io:println("Warning: deleteObject(sample.txt) failed: " + delErr.message());
        }
        error? delErr2 = s3Client->deleteObject(bucketName, "binary.bin");
        if delErr2 is error {
            io:println("Warning: deleteObject(binary.bin) failed: " + delErr2.message());
        }
        error? delErr3 = s3Client->deleteObject(bucketName, "sample-copy.txt");
        if delErr3 is error {
            io:println("Warning: deleteObject(sample-copy.txt) failed: " + delErr3.message());
        }

        error? bucketDelErr = s3Client->deleteBucket(bucketName);
        if bucketDelErr is error {
            io:println("Warning: deleteBucket failed: " + bucketDelErr.message());
        }

        return e;
    }
}
