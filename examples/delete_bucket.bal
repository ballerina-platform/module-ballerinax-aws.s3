import ballerina/log;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string bucketName = ?;

s3:ConnectionConfig amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

final s3:Client amazonS3Client = check new (amazonS3Config);

public function main() {
    error? deleteBucketResponse = amazonS3Client->deleteBucket(bucketName);
    if deleteBucketResponse is error {
        log:printError("Error occurred while deleting bucket", deleteBucketResponse);
    } else {
        log:printInfo("Successfully deleted bucket");
    }
}
