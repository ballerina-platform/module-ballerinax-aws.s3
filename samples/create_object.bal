import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() {
    s3:ConnectorError? createObjectResponse = amazonS3Client->createObject(bucketName, "test.txt", "Sample content");
    if (createObjectResponse is s3:ConnectorError) {
        io:println("Error: ", createObjectResponse.message());
    } else {
        io:println("Object created successfully");
    }
}
