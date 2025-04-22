import ballerina/log;
import ballerinax/aws.s3;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;

s3:ConnectionConfig amazonS3Config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

final s3:Client amazonS3Client = check new (amazonS3Config);

public function main() returns error? {
    s3:Bucket[]|error listBucketResponse = amazonS3Client->listBuckets();
    if listBucketResponse is error {
        log:printError("Error occurred while listing buckets", listBucketResponse);
        return listBucketResponse;
    }
    log:printInfo("Listing all buckets: ");
    foreach var bucket in listBucketResponse {
        log:printInfo("Bucket Name: " + bucket.name);
    }
}
