// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
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

import ballerina/os;
import ballerina/test;

// Environment variables for authentication
final string authType = os:getEnv("AUTH_TYPE");
final string accessKeyId = os:getEnv("ACCESS_KEY_ID");
final string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
final string profileName = os:getEnv("AWS_PROFILE_NAME");
final string credentialsFilePath = os:getEnv("AWS_CREDENTIALS_FILE");

// AWS Region for testing
final Region awsRegion = EU_NORTH_1;

// Static credentials configuration
final readonly & StaticAuthConfig staticAuth = {
    accessKeyId,
    secretAccessKey
};

// Profile-based credentials configuration
final readonly & ProfileAuthConfig profileAuth = {
    profileName: profileName,
    credentialsFilePath: credentialsFilePath
};

// Initialize S3 client with appropriate auth strategy
final Client s3Client = check initS3Client();

function initS3Client() returns Client|error {
    if authType == "default" {
        return new ({
            region: awsRegion,
            auth: DEFAULT_CREDENTIALS
        });
    } else if authType == "profile" {
        return new ({
            region: awsRegion,
            auth: profileAuth
        });
    } else if accessKeyId != "" && secretAccessKey != "" {
        return new ({
            region: awsRegion,
            auth: staticAuth
        });
    }
    return test:mock(Client);
}

// Helper function to create a client with a different region
// Uses the same auth approach as the main client
function createS3ClientWithRegion(Region targetRegion) returns Client|error {
    if authType == "default" {
        return new ({
            region: targetRegion,
            auth: DEFAULT_CREDENTIALS
        });
    } else if authType == "profile" {
        return new ({
            region: targetRegion,
            auth: profileAuth
        });
    } else if accessKeyId != "" && secretAccessKey != "" {
        return new ({
            region: targetRegion,
            auth: staticAuth
        });
    }
    return test:mock(Client);
}
