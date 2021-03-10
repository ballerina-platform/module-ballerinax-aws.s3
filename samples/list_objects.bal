import ballerina/log;
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

public function main() returns error? {
    var listObjectsResponse = amazonS3Client->listObjects(bucketName);
    if (listObjectsResponse is s3:S3Object[]) {
        log:print("Listing all object: ");
        foreach var s3Object in listObjectsResponse {
            log:print("---------------------------------");
            log:print("Object Name: " + s3Object["objectName"].toString());
            log:print("Object Size: " + s3Object["objectSize"].toString());
        }
    } else {
        log:printError("Error: " + listObjectsResponse.toString());
    }
}
