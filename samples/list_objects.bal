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

public function main() returns error? {
    var listObjectsResponse = amazonS3Client->listObjects(bucketName);
    if (listObjectsResponse is s3:S3Object[]) {
        io:println("Listing all object: ");
        foreach var s3Object in listObjectsResponse {
            io:println("---------------------------------");
            io:println("Object Name: ", s3Object["objectName"]);
            io:println("Object Size: ", s3Object["objectSize"]);
        }
    } else {
        io:println("Error: ", listObjectsResponse);
    }
}
