// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/ftp;
import ballerina/io;
import ballerina/log;
import ballerinax/aws;
import ballerinax/aws.s3;

configurable string s3AccessKeyId = ?;
configurable string s3SecretAccessKey = ?;
configurable string s3BucketName = ?;
configurable aws:Region s3Region = ?;

configurable string ftpHost = ?;
configurable int ftpPort = 21;
configurable string ftpUser = ?;
configurable string ftpPassword = ?;
configurable string ftpRemoteDir = "/";

ftp:Client ftpClient = check new ({
    protocol: ftp:FTP,
    host: ftpHost,
    port: ftpPort,
    auth: {
        credentials: {
            username: ftpUser,
            password: ftpPassword
        }
    }
});

s3:Client s3Client = check new ({
    region: s3Region,
    auth: {
        accessKeyId: s3AccessKeyId,
        secretAccessKey: s3SecretAccessKey
    }
});

public function main() returns error? {
    // List files in the FTP directory
    ftp:FileInfo[] fileList = check ftpClient->list(ftpRemoteDir);

    foreach ftp:FileInfo fileInfo in fileList {
        string remotePath = ftpRemoteDir + "/" + fileInfo.name;
        if check ftpClient->isDirectory(remotePath) {
            continue;
        }

        // Download file content from FTP
        stream<byte[] & readonly, io:Error?> fileStream = check ftpClient->get(remotePath);
        byte[] content = [];
        check fileStream.forEach(function(byte[] & readonly chunk) {
            content.push(...chunk);
        });
        check fileStream.close();

        // Upload to S3
        check s3Client->putObject(s3BucketName, fileInfo.name, content);
        log:printInfo(string `Uploaded: ${fileInfo.name}`);
    }

    check s3Client.close();
}
