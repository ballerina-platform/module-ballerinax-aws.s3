// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/stringutils;

public type AmazonS3Client client object {

    public string accessKeyId;
    public string secretAccessKey;
    public string region;
    public string amazonHost = EMPTY_STRING;
    public http:Client amazonS3;

    public function __init(ClientConfiguration amazonS3Config) returns ClientError? {
        self.region = amazonS3Config.region;
        if (self.region != DEFAULT_REGION) {
            string|StringUtilError amazonHostVar = stringutils:replaceFirst(AMAZON_AWS_HOST, SERVICE_NAME, SERVICE_NAME + "." + self.region);
            if (amazonHostVar is string) {
                self.amazonHost = amazonHostVar;
            } else {
                ClientError clientError =
                    error(CLIENT_CONFIG_INITIALIZATION_ERROR, message = STRING_MANUPULATION_ERROR_MSG,
                                cause = amazonHostVar);
                return clientError;
            }
        } else {
            self.amazonHost = AMAZON_AWS_HOST;
        }
        string baseURL = HTTPS + self.amazonHost;
        self.accessKeyId = amazonS3Config.accessKeyId;
        self.secretAccessKey = amazonS3Config.secretAccessKey;
        ClientError? verificationStatus = verifyCredentials(self.accessKeyId, self.secretAccessKey);
        if (verificationStatus is ClientError) {
            ClientError clientConfigInitializationError = error(CLIENT_CONFIG_INITIALIZATION_ERROR,
                        message = CLIENT_CREDENTIALS_VERIFICATION_ERROR_MSG, cause = verificationStatus);
            return clientConfigInitializationError;
        } else {
            http:ClientSecureSocket? clientSecureSocket = amazonS3Config?.secureSocketConfig;
            if (clientSecureSocket is http:ClientSecureSocket) {
                amazonS3Config.clientConfig.secureSocket = clientSecureSocket;
            }
                self.amazonS3  = new(baseURL, amazonS3Config.clientConfig);
        }
    }

    # Retrieves a list of all Amazon S3 buckets that the authenticated user of the request owns.
    # 
    # + return - If success, returns a list of Bucket record, else returns ConnectorError
    public remote function listBuckets() returns @tainted Bucket[]|ConnectorError {
        map<string> requestHeaders = {};
        http:Request request = new;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        
        var signature = check generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                                self.region, GET, SLASH,
                                                                UNSIGNED_PAYLOAD, requestHeaders);

        var httpResponse = self.amazonS3->get(SLASH, message = request);
        if (httpResponse is http:Response) {
            xml|error xmlPayload = httpResponse.getXmlPayload();
            if (xmlPayload is xml) {
                if (httpResponse.statusCode == http:STATUS_OK) {
                    return getBucketsList(xmlPayload);
                } else {
                    string errorReason = ERROR_REASON_PREFIX + (xmlPayload/<Code>/*).toString();
                    string errorMessage = (xmlPayload/<Message>/*).toString();
                    error err = error(errorReason, message = errorMessage);
                    if (err is BucketOperationError) {
                        return err;
                    } else {
                        UnknownServerError unknownServerError = error(UNKNOWN_SERVER_ERROR, message = UNKNOWN_SERVER_ERROR_MSG,
                                                                                  cause = err);
                        return unknownServerError;
                    }
                }
            } else {
                ClientError httpResponseHandlingError = error(HTTP_RESPONSE_HANDLING_ERROR,
                                                  message = XML_EXTRACTION_ERROR_MSG, cause = xmlPayload);
                return httpResponseHandlingError;
            }
        } else {
            string message = API_INVOCATION_ERROR_MSG + "listing buckets.";
            ClientError apiInvocationError = error(API_INVOCATION_ERROR, message = message);
            return apiInvocationError;
        }
    }

    # Create a bucket.
    # 
    # + bucketName - Unique name for the bucket to create.
    # + cannedACL - The access control list of the new bucket.
    # 
    # + return - If failed turns ConnectorError.
    public remote function createBucket(string bucketName, public CannedACL? cannedACL = ()) returns @tainted ConnectorError? {
        map<string> requestHeaders = {};
        http:Request request = new;
        string requestURI = string `/${bucketName}/`;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        if (cannedACL != ()) {
            requestHeaders[X_AMZ_ACL] = cannedACL.toString();
        }
        if(self.region != DEFAULT_REGION) {
            xml xmlPayload = xml `<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"> 
                                        <LocationConstraint>${self.region}</LocationConstraint> 
                                </CreateBucketConfiguration>`;   
            request.setXmlPayload(xmlPayload);
        }
        var signature = check generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                    self.region, PUT, requestURI,
                                                    UNSIGNED_PAYLOAD, requestHeaders);

        var httpResponse = self.amazonS3->put(requestURI, request);
        if (httpResponse is http:Response) {
            return handleHttpResponse(httpResponse);
        } else {
            string message = API_INVOCATION_ERROR_MSG + "creating bucket.";
            ClientError apiInvocationError = error(API_INVOCATION_ERROR, message = message);
            return apiInvocationError;
        }
    }

    # Retrieve the existing objects in a given bucket
    # 
    # + bucketName - The name of the bucket.
    # + delimiter - A delimiter is a character you use to group keys.
    # + encodingType - The encoding method to be applied on the response.
    # + maxKeys - The maximum number of keys to include in the response.
    # + prefix - The prefix of the objects to be listed. If unspecified, all objects are listed.
    # + startAfter - Object key from where to begin listing.
    # + fetchOwner - Set to true, to retrieve the owner information in the response. By default the API does not return
    #                the Owner information in the response.
    # + continuationToken - When the response to this API call is truncated (that is, the IsTruncated response element 
    #                       value is true), the response also includes the NextContinuationToken element. 
    #                       To list the next set of objects, you can use the NextContinuationToken element in the next 
    #                       request as the continuation-token.
    # 
    # + return - If success, returns S3Object[] object, else returns ConnectorError
    public remote function listObjects(string bucketName, public string? delimiter = (), public string? encodingType = (), 
                        public int? maxKeys = (), public string? prefix = (), public string? startAfter = (), public boolean? fetchOwner = (), 
                        public string? continuationToken = ()) returns @tainted S3Object[]|ConnectorError {
        map<string> requestHeaders = {};
        map<string> queryParamsMap = {};  
        http:Request request = new;
        string requestURI = string `/${bucketName}/`;
        string queryParamsStr = "?list-type=2";
        queryParamsMap["list-type"] = "2";

        string queryParams = populateOptionalParameters(queryParamsMap, delimiter = delimiter, encodingType = encodingType, 
                                maxKeys = maxKeys, prefix = prefix, startAfter = startAfter, fetchOwner = fetchOwner, 
                                continuationToken = continuationToken);
        queryParamsStr = string `${queryParamsStr}${queryParams}`;
        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        var signature = check generateSignature(request, self.accessKeyId, self.secretAccessKey,
                            self.region, GET, requestURI, UNSIGNED_PAYLOAD, requestHeaders, queryParams = queryParamsMap);

        requestURI = string `${requestURI}${queryParamsStr}`;
        var httpResponse = self.amazonS3->get(requestURI, message = request);
        if (httpResponse is http:Response) {
            xml|error xmlPayload = httpResponse.getXmlPayload();
            if (xmlPayload is xml) {
                if (httpResponse.statusCode == http:STATUS_OK) {
                    return getS3ObjectsList(xmlPayload);
                } else {
                    string errorReason = ERROR_REASON_PREFIX + (xmlPayload/<Code>/*).toString();
                    string errorMessage = (xmlPayload/<Message>/*).toString();
                    error err = error(errorReason, message = errorMessage);
                    if (err is BucketOperationError) {
                        return err;
                    } else {
                        UnknownServerError unknownServerError = error(UNKNOWN_SERVER_ERROR, message = UNKNOWN_SERVER_ERROR_MSG,
                                                                                                      cause = err);
                        return unknownServerError;
                    }
                } 
            } else {
                ClientError httpResponseHandlingError = error(HTTP_RESPONSE_HANDLING_ERROR,
                                          message = XML_EXTRACTION_ERROR_MSG, cause = xmlPayload);
                return httpResponseHandlingError;
            }
        } else {
            string message = API_INVOCATION_ERROR_MSG + "listing objects from bucket " + bucketName;
            ClientError apiInvocationError = error(API_INVOCATION_ERROR, message = message);
            return apiInvocationError;
        }
    }

     # Retrieves objects from Amazon S3.
     #
     # + bucketName - The name of the bucket.
     # + objectName - The name of the object.
     # + objectRetrievalHeaders - Optional headers for the get object function.
     #
     # + return - If success, returns S3ObjectContent object, else returns ConnectorError
     public remote function getObject(string bucketName, string objectName,
                         public ObjectRetrievalHeaders? objectRetrievalHeaders = ()) returns @tainted S3Object|ConnectorError {
        map<string> requestHeaders = {};
        http:Request request = new;
        string requestURI = string `/${bucketName}/${objectName}`;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        // Add optional headers.
        populateGetObjectHeaders(requestHeaders, objectRetrievalHeaders);
        
        var signature = check generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET,
                                                 requestURI, UNSIGNED_PAYLOAD, requestHeaders);

        var httpResponse = self.amazonS3->get(requestURI, message = request);
        if (httpResponse is http:Response) {
            if (httpResponse.statusCode == http:STATUS_OK) {
                byte[]|error binaryPayload = extractResponsePayload(httpResponse);
                if (binaryPayload is error) {
                    ClientError httpResponseHandlingError = error(HTTP_RESPONSE_HANDLING_ERROR,
                                           message = BINARY_CONTENT_EXTRACTION_ERROR_MSG, cause = binaryPayload);
                    return httpResponseHandlingError;
                } else {
                    return getS3Object(binaryPayload);
                }
            } else {
                xml|error xmlPayload = httpResponse.getXmlPayload();
                if (xmlPayload is xml) {
                    string errorReason = ERROR_REASON_PREFIX + (xmlPayload/<Code>/*).toString();
                    string errorMessage = (xmlPayload/<Message>/*).toString();
                    error err = error(errorReason, message = errorMessage);
                    if (err is BucketOperationError) {
                        return err;
                    } else {
                        UnknownServerError unknownServerError = error(UNKNOWN_SERVER_ERROR, message = UNKNOWN_SERVER_ERROR_MSG,
                                                                                                      cause = err);
                        return unknownServerError;
                    }
                } else {
                    ClientError httpResponseHandlingError = error(HTTP_RESPONSE_HANDLING_ERROR,
                                             message = XML_EXTRACTION_ERROR_MSG, cause = xmlPayload);
                    return httpResponseHandlingError;
                }
            }
        } else {
            string message = API_INVOCATION_ERROR_MSG + "extracting object " + objectName + " from bucket " + bucketName;
            ClientError apiInvocationError = error(API_INVOCATION_ERROR, message = message);
            return apiInvocationError;
        }
    }

    # Create an object.
    #
    # + bucketName - The name of the bucket.
    # + objectName - The name of the object.
    # + payload - The file content that needed to be added to the bucket.
    # + cannedACL - The access control list of the new object.
    # + objectCreationHeaders - Optional headers for the create object function.
    #
    # + return - If failed returns ConnectorError
    public remote function createObject(string bucketName, string objectName, string|xml|json|byte[] payload,
                         public CannedACL? cannedACL = (), public ObjectCreationHeaders? objectCreationHeaders = ())
                         returns @tainted ConnectorError? {
        map<string> requestHeaders = {};
        http:Request request = new;
        string requestURI = string `/${bucketName}/${objectName}`;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;

        if (payload is byte[]) {
            request.setBinaryPayload(payload, contentType = "application/octet-stream");
        } else {
            request.setPayload(payload);
        }

        // Add optional headers.
        populateCreateObjectHeaders(requestHeaders, objectCreationHeaders);

        var signature = check generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, PUT,
                                                 requestURI, UNSIGNED_PAYLOAD, requestHeaders);

        var httpResponse = self.amazonS3->put(requestURI, request);
        if (httpResponse is http:Response) {
            return handleHttpResponse(httpResponse);
        } else {
            string message = API_INVOCATION_ERROR_MSG + "creating object.";
            ClientError apiInvocationError = error(API_INVOCATION_ERROR, message = message);
            return apiInvocationError;
        }
    }

    # Delete an object.
    # 
    # + bucketName - The name of the bucket.
    # + objectName - The name of the object
    # + versionId - The specific version of the object to delete, if versioning is enabled.
    # 
    # + return - If failed returns ConnectorError
    public remote function deleteObject(string bucketName, string objectName, public string? versionId = ()) 
                        returns @tainted ConnectorError? {
        map<string> requestHeaders = {};
        map<string> queryParamsMap = {};
        http:Request request = new;
        string queryParamsStr = "";
        string requestURI = string `/${bucketName}/${objectName}`;

        // Append query parameter(versionId).
        if (versionId is string) {
            queryParamsStr = string `${queryParamsStr}?versionId=${versionId}`;
            queryParamsMap["versionId"] = versionId;
        } 
        
        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        var signature = check generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE,
                                        requestURI, UNSIGNED_PAYLOAD, requestHeaders, queryParams = queryParamsMap);

        requestURI = string `${requestURI}${queryParamsStr}`;
        var httpResponse = self.amazonS3->delete(requestURI, request);
        if (httpResponse is http:Response) {
            return handleHttpResponse(httpResponse);
        } else {
            string message = API_INVOCATION_ERROR_MSG + "deleting object " + objectName + " from bucket " + bucketName;
            ClientError apiInvocationError = error(API_INVOCATION_ERROR, message = message);
            return apiInvocationError;
        }
    }     

    # Delete a bucket.
    # 
    # + bucketName - The name of the bucket.
    # 
    # + return - If failed returns ConnectorError
    public remote function deleteBucket(string bucketName) returns @tainted ConnectorError? {
        map<string> requestHeaders = {};
        http:Request request = new;
        string requestURI = string `/${bucketName}`;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        var signature = check generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, DELETE,
                                                requestURI, UNSIGNED_PAYLOAD, requestHeaders);

        var httpResponse = self.amazonS3->delete(requestURI, request);
        if (httpResponse is http:Response) {
            return handleHttpResponse(httpResponse);
        } else {
            string message = API_INVOCATION_ERROR_MSG + "deleting bucket " + bucketName;
            ClientError apiInvocationError = error(API_INVOCATION_ERROR, message = message);
            return apiInvocationError;
        }
    }
};

# Verify the existence of credentials.
#
# + accessKeyId - The access key is of the Amazon S3 account.
# + secretAccessKey - The secret access key of the Amazon S3 account.
# 
# + return - Returns an error object if accessKeyId or secretAccessKey not exists.
function verifyCredentials(string accessKeyId, string secretAccessKey) returns ClientError? {
    if ((accessKeyId == "") || (secretAccessKey == "")) {
        ClientError clientCredentialsVerificationError = error(CLIENT_CREDENTIALS_VERIFICATION_ERROR,
                            message = EMPTY_VALUES_FOR_CREDENTIALS_ERROR_MSG);
        return clientCredentialsVerificationError;
    }
}

# AmazonS3 Connector configurations can be setup here.
# + accessKeyId - The access key is of the Amazon S3 account.
# + secretAccessKey - The secret access key of the Amazon S3 account.
# + region - The AWS Region. If you don't specify an AWS region, AmazonS3Client uses US East (N. Virginia) as 
#            default region.
# + clientConfig - HTTP client config
# + secureSocketConfig - Secure Socket config
public type ClientConfiguration record {
    string accessKeyId;
    string secretAccessKey;
    string region = DEFAULT_REGION;
    http:ClientConfiguration clientConfig = {http1Settings: {chunking: http:CHUNKING_NEVER}};
    http:ClientSecureSocket secureSocketConfig?;
};
