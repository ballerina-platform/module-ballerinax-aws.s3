//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
//

import ballerina/http;

# Amazons3 Client object.
#
# + accessKeyId - The access key is of the Amazon S3 account
# + secretAccessKey - The secret access key of the Amazon S3 account
# + region - The AWS Region
# + amazonHost - The AWS Host
# + amazonS3Client - HTTP Client endpoint
# + baseURL - Base url
public type Client client object {

    public string accessKeyId;
    public string secretAccessKey;
    public string region;
    public string amazonHost;
    public string baseURL = "";
    public http:Client amazonS3Client;

    public function __init(AmazonS3Configuration amazonS3Config) {
        self.amazonHost = amazonS3Config.amazonHost;
        string baseURL = HTTPS + amazonS3Config.amazonHost;
        self.accessKeyId = amazonS3Config.accessKeyId;
        self.secretAccessKey = amazonS3Config.secretAccessKey;
        self.region = amazonS3Config.region;
        self.amazonS3Client = new(baseURL, config = amazonS3Config.clientConfig);
    }

    # Retrieve the existing buckets.
    # + return - If success, returns BucketList object, else returns error
    public remote function getBucketList() returns Bucket[]|error;

    # Create a bucket.
    # + return - If success, returns Status object, else returns error
    public remote function createBucket(string bucketName) returns Status|error;

    # Retrieve the existing objects in a given bucket.
    # + bucketName - The name of the bucket
    # + return - If success, returns S3Object[] object, else returns error
    public remote function getAllObjects(string bucketName) returns S3Object[]|error;

    # Retrieves objects from Amazon S3.
    # + bucketName - The name of the bucket
    # + objectName - The name of the object
    # + return - If success, returns S3ObjectContent object, else returns error
    public remote function getObject(string bucketName, string objectName) returns S3Object|error;

    # Create an object.
    # + objectName - The name of the object
    # + payload - The file that needed to be added to the bucket
    # + return - If success, returns Status object, else returns error
    public remote function createObject(string bucketName, string objectName, string payload) returns Status|error;

    # Delete an object.
    # + objectName - The name of the object
    # + return - If success, returns Status object, else returns error
    public remote function deleteObject(string bucketName, string objectName) returns Status|error;

    # Delete a bucket.
    # + return - If success, returns Status object, else returns error
    public remote function deleteBucket(string bucketName) returns Status|error;
};

public remote function Client.getBucketList() returns Bucket[]|error {

    http:Request request = new;
    string requestURI = "/";

    request.setHeader(HOST, self.amazonHost);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI,
        UNSIGNED_PAYLOAD);

    if (signature is error) {
        error err = error(AMAZONS3_ERROR_CODE, { cause: signature,
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var httpResponse = self.amazonS3Client->get("/", message = request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var amazonResponse = httpResponse.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getBucketsList(amazonResponse);
                }
                return setResponseError(statusCode, amazonResponse);
            } else {
                error err = error(AMAZONS3_ERROR_CODE,
                { message: "Error occurred while accessing the xml payload of the response." });
                return err;
            }
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while invoking the AmazonS3 API" });
            return err;
        }
    }
}

public remote function Client.createBucket(string bucketName) returns Status|error {

    http:Request request = new;
    string requestURI = "/" + bucketName + "/";

    request.setHeader(HOST, self.amazonHost);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI,
        UNSIGNED_PAYLOAD);

    if (signature is error) {
        error err = error(AMAZONS3_ERROR_CODE, { cause: signature,
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var httpResponse = self.amazonS3Client->put(requestURI, request);
        if (httpResponse is http:Response) {
            return getStatus(httpResponse.statusCode);
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while invoking the AmazonS3 API" });
            return err;
        }
    }
}

public remote function Client.getAllObjects(string bucketName) returns S3Object[]|error {

    http:Request request = new;
    string requestURI = "/" + bucketName + "/";

    request.setHeader(HOST, self.amazonHost);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI,
        UNSIGNED_PAYLOAD);

    if (signature is error) {
        error err = error(AMAZONS3_ERROR_CODE, { cause: signature,
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var httpResponse = self.amazonS3Client->get(requestURI, message = request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            var amazonResponse = httpResponse.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getS3ObjectsList(amazonResponse);
                }
                return setResponseError(statusCode, amazonResponse);
            } else {
                error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while accessing the xml payload
                of the response." });
                return err;
            }
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while invoking the AmazonS3 API" });
            return err;
        }
    }
}

public remote function Client.getObject(string bucketName, string objectName) returns S3Object|error {

    http:Request request = new;
    string requestURI = "/" + bucketName + "/" + objectName;

    request.setHeader(HOST, self.amazonHost);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI,
        UNSIGNED_PAYLOAD);

    if (signature is error) {
        error err = error(AMAZONS3_ERROR_CODE, { cause: signature,
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var httpResponse = self.amazonS3Client->get(requestURI, message = request);
        if (httpResponse is http:Response) {
            int statusCode = httpResponse.statusCode;
            string|error amazonResponse = httpResponse.getTextPayload();
            if (amazonResponse is string) {
                if (statusCode == 200) {
                    return getS3Object(amazonResponse);
                } else {
                    error err = error(AMAZONS3_ERROR_CODE,
                    { message: "Error occurred while getting the amazonS3 object." });
                    return err;
                }
            } else {
                error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while accessing the string payload
                            of the response." });
                return err;
            }
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while invoking the AmazonS3 API" });
            return err;
        }
    }
}

public remote function Client.createObject(string bucketName, string objectName, string payload) returns Status|error {

    http:Request request = new;
    string requestURI = "/" + bucketName + "/" + objectName;

    request.setHeader(HOST, self.amazonHost);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    request.setTextPayload(payload);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI,
        UNSIGNED_PAYLOAD);
    if (signature is error) {
        error err = error(AMAZONS3_ERROR_CODE, { cause: signature,
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var httpResponse = self.amazonS3Client->put(requestURI, request);
        if (httpResponse is http:Response) {
            return getStatus(httpResponse.statusCode);
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while invoking the AmazonS3 API" });
            return err;
        }
    }
}

public remote function Client.deleteObject(string bucketName, string objectName) returns Status|error {

    http:Request request = new;
    string requestURI = "/" + bucketName + "/" + objectName;

    request.setHeader(HOST, self.amazonHost);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
        UNSIGNED_PAYLOAD);

    if (signature is error) {
        error err = error(AMAZONS3_ERROR_CODE, { cause: signature,
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var httpResponse = self.amazonS3Client->delete(requestURI, request);
        if (httpResponse is http:Response) {
            return getStatus(httpResponse.statusCode);
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while invoking the AmazonS3 API" });
            return err;
        }
    }
}

public remote function Client.deleteBucket(string bucketName) returns Status|error {

    http:Request request = new;
    string requestURI = "/" + bucketName;

    request.setHeader(HOST, self.amazonHost);
    request.setHeader(X_AMZ_CONTENT_SHA256, UNSIGNED_PAYLOAD);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
        UNSIGNED_PAYLOAD);

    if (signature is error) {
        error err = error(AMAZONS3_ERROR_CODE, { cause: signature,
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var httpResponse = self.amazonS3Client->delete(requestURI, request);
        if (httpResponse is http:Response) {
            return getStatus(httpResponse.statusCode);
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred while invoking the AmazonS3 API" });
            return err;
        }
    }
}

# AmazonS3 Connector configurations can be setup here.
# + accessKeyId - The access key is of the Amazon S3 account
# + secretAccessKey - The secret access key of the Amazon S3 account
# + region - The AWS Region
# + amazonHost - The AWS host
# + clientConfig - HTTP client config
public type AmazonS3Configuration record {
    string accessKeyId = "";
    string secretAccessKey = "";
    string region = "";
    string amazonHost = "";
    http:ClientEndpointConfig clientConfig = {};
};
