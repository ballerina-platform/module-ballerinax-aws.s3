import ballerina/io;
import ballerina/log;
import ballerina/lang.'string as strings;
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

s3:Client amazonS3Client = check new (amazonS3Config);

public function main() returns error? {
    stream<byte[], io:Error?>|error getObjectResponse = amazonS3Client->getObject(bucketName, "test.txt");
    if (getObjectResponse is stream<byte[], io:Error?>) {
        error? err = getObjectResponse.forEach(isolated function(byte[] res) {
            error? writeRes = io:fileWriteBytes("./resources/test.txt", res, io:APPEND);
        });
    } else {
        log:printError("Error: " + getObjectResponse.toString());
    }
}
