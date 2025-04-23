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

public function main() returns error? {
    s3:S3Object[]|error listObjectsResponse = amazonS3Client->listObjects(bucketName);
    if listObjectsResponse is error {
        log:printError("Error occurred while listing objects", listObjectsResponse);
        return listObjectsResponse;
    }
    log:printInfo("Listing all object: ");
    foreach s3:S3Object s3Object in listObjectsResponse {
        log:printInfo("---------------------------------");
        log:printInfo("Object Name: " + s3Object["objectName"].toString());
        log:printInfo("Object Size: " + s3Object["objectSize"].toString());
    }
}
