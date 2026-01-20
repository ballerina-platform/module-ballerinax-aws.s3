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

    // 1. Upload String content
    string textContent = "Hello from Ballerina S3 Connector!";
    check s3Client->putObject(bucketName, "sample.txt", textContent);
    io:println("String object uploaded: sample.txt");

    // 2. Upload JSON content
    json jsonData = {"name": "John Doe", "age": 30, "city": "New York"};
    check s3Client->putObject(bucketName, "data.json", jsonData);
    io:println("JSON object uploaded: data.json");

    // 3. Upload XML content
    xml xmlData = xml `<user><name>Jane Doe</name><role>Admin</role></user>`;
    check s3Client->putObject(bucketName, "config.xml", xmlData);
    io:println("XML object uploaded: config.xml");

    // 4. Upload Byte array
    byte[] binaryData = [72, 101, 108, 108, 111];
    check s3Client->putObject(bucketName, "binary.bin", binaryData);
    io:println("Binary object uploaded: binary.bin");

    // 5. Retrieve String content
    string retrievedText = check s3Client->getObject(bucketName, "sample.txt", string);
    io:println("Retrieved text: " + retrievedText);

    // 6. Retrieve JSON content
    json retrievedJson = check s3Client->getObject(bucketName, "data.json", json);
    io:println("Retrieved JSON: " + retrievedJson.toJsonString());

    // 7. Get object metadata
    s3:ObjectMetadata metadata = check s3Client->getObjectMetadata(bucketName, "sample.txt");
    io:println("Object metadata - Size: " + metadata.contentLength.toString() + " bytes");

    // 8. Copy object
    check s3Client->copyObject(bucketName, "sample.txt", bucketName, "sample-copy.txt");
    io:println("Object copied: sample.txt -> sample-copy.txt");

    // 9. List objects in bucket
    _ = check s3Client->listObjects(bucketName);
    io:println("Objects listed successfully.");

    // 10. Delete objects
    check s3Client->deleteObject(bucketName, "sample.txt");
    check s3Client->deleteObject(bucketName, "sample-copy.txt");
    check s3Client->deleteObject(bucketName, "data.json");
    check s3Client->deleteObject(bucketName, "config.xml");
    check s3Client->deleteObject(bucketName, "binary.bin");
    io:println("All objects deleted.");

    check s3Client->deleteBucket(bucketName);
    io:println("Bucket deleted: " + bucketName);
}