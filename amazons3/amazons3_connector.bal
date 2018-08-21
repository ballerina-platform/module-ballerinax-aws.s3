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

function AmazonS3Connector::getBucketList() returns Bucket[]|AmazonS3Error {

    endpoint http:Client clientEndpoint = getClientEndpoint("");

    AmazonS3Error amazonS3Error = {};
    http:Request request = new;
    string requestURI = "/";
    string host = AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = clientEndpoint->get("/", message = request);
    match httpResponse {
        error err => {
            amazonS3Error.message = err.message;
            amazonS3Error.cause = err.cause;
            return amazonS3Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonS3Error.message = err.message;
                    amazonS3Error.cause = err.cause;
                    return amazonS3Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getBucketsList(xmlResponse);
                    } else {
                        amazonS3Error.message = xmlResponse["Message"].getTextValue();
                        amazonS3Error.statusCode = statusCode;
                        return amazonS3Error;
                    }
                }
            }
        }
    }
}

function AmazonS3Connector::createBucket(string bucketName) returns Status|AmazonS3Error {

    endpoint http:Client clientEndpoint = getClientEndpoint(bucketName);

    AmazonS3Error amazonS3Error = {};
    http:Request request = new;
    string requestURI = "/";
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = clientEndpoint->put("/", request);
    match httpResponse {
        error err => {
            amazonS3Error.message = err.message;
            amazonS3Error.cause = err.cause;
            return amazonS3Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            return getStatus(statusCode);
        }
    }
}

function AmazonS3Connector::getAllObjects(string bucketName) returns S3Object[]|AmazonS3Error {

    endpoint http:Client clientEndpoint = getClientEndpoint(bucketName);

    AmazonS3Error amazonS3Error = {};
    http:Request request = new;
    string requestURI = "/";
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = clientEndpoint->get("/", message = request);
    match httpResponse {
        error err => {
            amazonS3Error.message = err.message;
            amazonS3Error.cause = err.cause;
            return amazonS3Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonS3Error.message = err.message;
                    amazonS3Error.cause = err.cause;
                    return amazonS3Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getS3ObjectsList(xmlResponse);
                    }
                    else{
                        amazonS3Error.message = xmlResponse["Message"].getTextValue();
                        amazonS3Error.statusCode = statusCode;
                        return amazonS3Error;
                    }
                }
            }
        }
    }
}

function AmazonS3Connector::getObject(string bucketName, string objectName) returns S3Object|AmazonS3Error {

    endpoint http:Client clientEndpoint = getClientEndpoint(bucketName);

    AmazonS3Error amazonS3Error = {};
    http:Request request = new;
    string requestURI = "/" + objectName;
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD);

    var httpResponse = clientEndpoint->get(requestURI, message = request);
    match httpResponse {
        error err => {
            amazonS3Error.message = err.message;
            amazonS3Error.cause = err.cause;
            return amazonS3Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getPayloadAsString();
            match amazonResponse {
                error err => {
                    amazonS3Error.message = err.message;
                    amazonS3Error.cause = err.cause;
                    return amazonS3Error;
                }
                string stringResponse => {
                    if (statusCode == 200) {
                        return getS3Object(stringResponse);
                    }
                    else{
                        amazonS3Error.statusCode = statusCode;
                        return amazonS3Error;
                    }
                }
            }
        }
    }
}

function AmazonS3Connector::createObject(string bucketName, string objectName, string payload) returns Status|AmazonS3Error {

    endpoint http:Client clientEndpoint = getClientEndpoint(bucketName);

    AmazonS3Error amazonS3Error = {};
    http:Request request = new;
    string requestURI = "/" + objectName;
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    request.setTextPayload(payload);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI, UNSIGNED_PAYLOAD);
    var httpResponse = clientEndpoint->put(requestURI, request);
    match httpResponse {
        error err => {
            amazonS3Error.message = err.message;
            amazonS3Error.cause = err.cause;
            return amazonS3Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            return getStatus(statusCode);
        }
    }
}

function AmazonS3Connector::deleteObject(string bucketName, string objectName) returns Status|AmazonS3Error {

    endpoint http:Client clientEndpoint = getClientEndpoint(bucketName);

    AmazonS3Error amazonS3Error = {};
    http:Request request = new;
    string requestURI = "/" + objectName;
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
        UNSIGNED_PAYLOAD);

    var httpResponse = clientEndpoint->delete(requestURI, request);
    match httpResponse {
        error err => {
            amazonS3Error.message = err.message;
            amazonS3Error.cause = err.cause;
            return amazonS3Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            return getStatus(statusCode);
        }
    }
}

function AmazonS3Connector::deleteBucket(string bucketName) returns Status|AmazonS3Error {

    endpoint http:Client clientEndpoint = getClientEndpoint(bucketName);

    AmazonS3Error amazonS3Error = {};
    http:Request request = new;
    string requestURI = "/";
    string host = bucketName + "."+ AMAZON_AWS_HOST;

    request.setHeader(HOST, host);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
        UNSIGNED_PAYLOAD);

    var httpResponse = clientEndpoint->delete(requestURI, request);
    match httpResponse {
        error err => {
            amazonS3Error.message = err.message;
            return amazonS3Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            return getStatus(statusCode);
        }
    }
}

function getClientEndpoint(string bucketName) returns http:Client {
    http:ClientEndpointConfig clientConfig = {};
    if (bucketName != "" ){
        clientConfig.url = HTTPS + bucketName + "." + AMAZON_AWS_HOST;
    } else {
        clientConfig.url = HTTPS + AMAZON_AWS_HOST;
    }
    http:Client clientEndpoint = new;
    clientEndpoint.init(clientConfig);
    return clientEndpoint;
}
