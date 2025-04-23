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
    error? deleteObjectResponse = amazonS3Client->deleteObject(bucketName, "test.txt");
    if deleteObjectResponse is error {
        log:printError("Error occurred while deleting object", deleteObjectResponse);
    } else {
        log:printInfo("Successfully deleted object");
    }
}
