import ballerina/io;
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
    stream<byte[], io:Error?>|error getObjectResponse = amazonS3Client->getObject(bucketName, "test.txt");
    if getObjectResponse is error {
        log:printError("Error occurred while getting object", getObjectResponse);
    } else {
        check getObjectResponse.forEach(isolated function(byte[] res) {
            error? writeRes = io:fileWriteBytes("./resources/test.txt", res, io:APPEND);
            if writeRes is error {
                log:printError("Error occurred while writing object", writeRes);
            }
        });
    }
}
