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

import ballerina/file;
import ballerina/ftp;
import ballerina/io;
import ballerina/log;
import ballerinax/aws;
import ballerinax/aws.s3;

configurable string s3AccessKeyId = ?;
configurable string s3SecretAccessKey = ?;
configurable string s3BucketName = ?;
configurable aws:Region s3Region = ?;
configurable string s3Prefix = ?;

configurable string ftpHost = ?;
configurable int ftpPort = 21;
configurable string ftpUser = ?;
configurable string ftpPassword = ?;
configurable string ftpRemoteDir = "/";

type SyncStats record {
    int totalFiles;
    int successfulUploads;
    int failedUploads;
    int skippedFiles;
    string[] errors;
};

function buildS3Key(string filename) returns string {
    return s3Prefix + "/" + filename;
}

function listFtpFiles(ftp:Client ftpClient) returns string[]|error {
    log:printInfo(string `Listing FTP directory: ${ftpRemoteDir}`);

    ftp:FileInfo[] fileList = check ftpClient->list(ftpRemoteDir);
    string[] filenames = [];

    foreach ftp:FileInfo fileInfo in fileList {
        string fullPath = ftpRemoteDir + "/" + fileInfo.name;
        boolean isDir = check ftpClient->isDirectory(fullPath);
        if !isDir {
            filenames.push(fileInfo.name);
        }
    }

    log:printInfo(string `Found ${filenames.length()} files`);
    return filenames;
}

function downloadFromFtp(ftp:Client ftpClient, string filename, string localPath) returns error? {
    string remotePath = ftpRemoteDir + "/" + filename;
    log:printInfo(string `Downloading: ${remotePath} → ${localPath}`);

    // Get file content as a stream from FTP
    stream<byte[] & readonly, io:Error?> fileStream = check ftpClient->get(remotePath);

    // Write stream to local temp file
    error? writeErr = io:fileWriteBlocksFromStream(localPath, fileStream);
    error? closeErr = fileStream.close();
    check writeErr;
    check closeErr;

    log:printInfo(string `Downloaded: ${filename}`);
}

function existsInS3(s3:Client s3Client, string filename) returns boolean|error {
    string s3Key = buildS3Key(filename);
    return s3Client->doesObjectExist(s3BucketName, s3Key);
}

function uploadToS3(s3:Client s3Client, string localFilePath, string filename) returns error? {
    string s3Key = buildS3Key(filename);
    log:printInfo(string `Uploading to S3: ${s3Key}`);

    byte[] fileContent = check io:fileReadBytes(localFilePath);
    check s3Client->putObject(s3BucketName, s3Key, fileContent);

    log:printInfo(string `Uploaded: ${s3Key}`);
}

function validateFilename(string filename) returns error? {
    if string:indexOf(filename, "/") >= 0 ||
        string:indexOf(filename, "\\") >= 0 ||
        string:indexOf(filename, "..") >= 0 {
        return error("Invalid FTP filename");
    }
}

function syncFtpToS3(ftp:Client ftpClient, s3:Client s3Client) returns SyncStats|error {
    SyncStats stats = {
        totalFiles: 0,
        successfulUploads: 0,
        failedUploads: 0,
        skippedFiles: 0,
        errors: []
    };

    string tempDir = "./ftp_sync_temp";
    check file:createDir(tempDir, file:RECURSIVE);

    do {
        string[] ftpFiles = check listFtpFiles(ftpClient);
        stats.totalFiles = ftpFiles.length();

        foreach string filename in ftpFiles {
            do {
                // Skip if already uploaded
                boolean exists = check existsInS3(s3Client, filename);
                if exists {
                    log:printInfo(string `Skipping (already in S3): ${filename}`);
                    stats.skippedFiles += 1;
                    continue;
                }

                check validateFilename(filename);
                string localPath = string `${tempDir}/${filename}`;

                check downloadFromFtp(ftpClient, filename, localPath);
                check uploadToS3(s3Client, localPath, filename);
                stats.successfulUploads += 1;

                // Clean up temp file immediately after upload
                check file:remove(localPath);

            } on fail error e {
                log:printError(string `Failed: ${filename} — ${e.message()}`, 'error = e);
                stats.failedUploads += 1;
                stats.errors.push(string `${filename}: ${e.message()}`);
            }
        }
    } on fail error e {
        file:Error? remove = file:remove(tempDir, file:RECURSIVE);
        return e;
    }

    // Clean up temp dir
    check file:remove(tempDir, file:RECURSIVE);
    return stats;
}

public function main() returns error? {

    // Initialize FTP client
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

    // Initialize S3 client
    s3:Client s3Client = check new ({
        region: s3Region,
        auth: {
            accessKeyId: s3AccessKeyId,
            secretAccessKey: s3SecretAccessKey
        }
    });

    _ = check syncFtpToS3(ftpClient, s3Client);
    check s3Client.close();
}
