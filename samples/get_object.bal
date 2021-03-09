import ballerina/io;
import ballerina/lang.'string as strings;
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

public function main() returns error? {
    var getObjectResponse = amazonS3Client->getObject(bucketName, "test.txt");
    if (getObjectResponse is s3:S3Object) {
        io:println(getObjectResponse);
        byte[]? byteArray = getObjectResponse["content"];
        if (byteArray is byte[]) {
            string content = check strings:fromBytes(byteArray);
            io:println("Object content: ", content);
        }
    } else {
        io:println("Error: ", getObjectResponse);
    }
}
