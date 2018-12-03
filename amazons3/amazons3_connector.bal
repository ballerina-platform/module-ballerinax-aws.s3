// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/io;
import ballerina/http;

# Define the AmazonS3 connector.
# + accessKeyId - The access key is of the Amazon S3 account
# + secretAccessKey - The secret access key of the Amazon S3 account
# + region - The AWS Region
# + amazonS3Client - HTTP Client endpoint
public type AmazonS3Connector client object {

    public string accessKeyId;
    public string secretAccessKey;
    public string region;
    public http:Client amazonS3Client;
    public function __init(string url, AmazonS3Configuration amazonS3Config) {
        self.amazonS3Client = new(url, config = amazonS3Config.clientConfig);
        self.accessKeyId = amazonS3Config.accessKeyId;
        self.secretAccessKey = amazonS3Config.secretAccessKey;
        self.region = amazonS3Config.region;
    }

    # Retrieve the existing buckets.
    # + return - If success, returns BucketList object, else returns error
    remote function getBucketList() returns Bucket[]|error;

    # Create a bucket.
    # + return - If success, returns Status object, else returns error
    remote function createBucket(string bucketName) returns Status|error;

    # Retrieve the existing objects in a given bucket.
    # + bucketName - The name of the bucket
    # + return - If success, returns S3Object[] object, else returns error
    remote function getAllObjects(string bucketName) returns S3Object[]|error;

    # Retrieves objects from Amazon S3.
    # + bucketName - The name of the bucket
    # + objectName - The name of the object
    # + return - If success, returns S3ObjectContent object, else returns error
    remote function getObject(string bucketName, string objectName) returns S3Object|error;

    # Create an object.
    # + objectName - The name of the object
    # + payload - The file that needed to be added to the bucket
    # + return - If success, returns Status object, else returns error
    remote function createObject(string bucketName, string objectName, string payload) returns Status|error;

    # Delete an object.
    # + objectName - The name of the object
    # + return - If success, returns Status object, else returns error
    remote function deleteObject(string bucketName, string objectName) returns Status|error;

    # Delete a bucket.
    # + return - If success, returns Status object, else returns error
    remote function deleteBucket(string bucketName) returns Status|error;
};

remote function AmazonS3Connector.getBucketList() returns Bucket[]|error {

    http:Request request = new;
    string requestURI = "/";
    string host = AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = self.amazonS3Client->get("/", message = request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var amazonResponse = httpResponse.getXmlPayload();
        if (amazonResponse is xml) {
            if (statusCode == 200) {
                return getBucketsList(amazonResponse);
            } else {
                return setResponseError(statusCode, amazonResponse);
            }
        } else {
            error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while accessing the xml payload
                            of the response." });
            return err;
        }
    } else {
        error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while invoking the AmazonS3 API" });
        return err;
    }
}

remote function AmazonS3Connector.createBucket(string bucketName) returns Status|error {

    http:Request request = new;
    string requestURI = "/";
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = self.amazonS3Client->put("/", request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        return getStatus(statusCode);
    } else {
        error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while invoking the AmazonS3 API" });
        return err;
    }
}

remote function AmazonS3Connector.getAllObjects(string bucketName) returns S3Object[]|error {

    http:Request request = new;
    string requestURI = "/";
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = self.amazonS3Client->get("/", message = request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var amazonResponse = httpResponse.getXmlPayload();
        if (amazonResponse is xml) {
            if (statusCode == 200) {
                return getS3ObjectsList(amazonResponse);
            }
            else{
                return setResponseError(statusCode, amazonResponse);
            }
        } else {
            error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while accessing the xml payload
                of the response." });
            return err;
        }
    } else {
        error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while invoking the AmazonS3 API" });
        return err;
    }
}

remote function AmazonS3Connector.getObject(string bucketName, string objectName) returns S3Object|error {

    http:Request request = new;
    string requestURI = "/" + objectName;
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = self.amazonS3Client->get(requestURI, message = request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var amazonResponse = httpResponse.getPayloadAsString();
        if (amazonResponse is string) {
            if (statusCode == 200) {
                return getS3Object(amazonResponse);
            }
            else{
                error err = error(<string>statusCode, { message : "Error occurred while getting the amazonS3 object." });
                return err;
            }
        } else {
        error err = error(AMAZONS3_ERROR_CODE, { message : "Error occurred while accessing the string payload
                        of the response." });
        return err;
        }
    } else {
        error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while invoking the AmazonS3 API" });
        return err;
    }
}

remote function AmazonS3Connector.createObject(string bucketName, string objectName, string payload) returns Status|error {

    http:Request request = new;
    string requestURI = "/" + objectName;
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    request.setTextPayload(payload);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI, UNSIGNED_PAYLOAD);
    var httpResponse = self.amazonS3Client->put(requestURI, request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        return getStatus(statusCode);
    } else {
        error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while invoking the AmazonS3 API" });
        return err;
    }
}

remote function AmazonS3Connector.deleteObject(string bucketName, string objectName) returns Status|error {

    http:Request request = new;
    string requestURI = "/" + objectName;
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
        UNSIGNED_PAYLOAD);

    var httpResponse = self.amazonS3Client->delete(requestURI, request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        return getStatus(statusCode);
    } else {
        error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while invoking the AmazonS3 API" });
        return err;
    }
}

remote function AmazonS3Connector.deleteBucket(string bucketName) returns Status|error {

    http:Client clientEndpoint = self.amazonS3Client;
    http:ClientEndpointConfig url = getClientEndpoint(bucketName);
    clientEndpoint.init(clientConfig);

    http:Request request = new;
    string requestURI = "/";
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
        UNSIGNED_PAYLOAD);

    var httpResponse = clientEndpoint->delete(requestURI, request);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        return getStatus(statusCode);
    } else {
        error err = error(AMAZONS3_ERROR_CODE, {message : "Error occurred while invoking the AmazonS3 API" });
        return err;
    }
}

function getClientEndpoint(string bucketName) returns http:ClientEndpointConfig{
    http:ClientEndpointConfig clientConfig = {};
    if (bucketName != "" ){
        clientConfig.url = HTTPS + bucketName + "." + AMAZON_AWS_HOST;
    } else {
        clientConfig.url = HTTPS + AMAZON_AWS_HOST;
    }
    return clientConfig;
}
