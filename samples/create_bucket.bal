import ballerina/io;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

// Create the ClientConfiguration that can be used to connect with the Amazon S3 service.
s3:ClientConfiguration amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

s3:Client amazonS3Client = checkpanic new (amazonS3Config);

public function main() {
    s3:CannedACL cannedACL = s3:ACL_PRIVATE;
    s3:ConnectorError? createBucketResponse = amazonS3Client->createBucket(bucketName, cannedACL);
    if (createBucketResponse is s3:ConnectorError) {
        io:println("Error: ", createBucketResponse.message());
    } else {
        io:println("Bucket Creation Status: Success");
    }
}
