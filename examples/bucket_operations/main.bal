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

    s3:Bucket[] buckets = check s3Client->listBuckets();
    io:println(string `Total buckets: ${buckets.length()}`);

    string location = check s3Client->getBucketLocation(bucketName);
    io:println("Bucket location: " + location);

    check s3Client->deleteBucket(bucketName);
    io:println("Bucket deleted: " + bucketName);
}
