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
import ballerina/io;

public type AmazonS3Client client object {

    public string accessKeyId;
    public string secretAccessKey;
    public string region;
    public string amazonHost = EMPTY_STRING;
    public http:Client amazonS3Client;

    public function __init(ClientConfiguration amazonS3Config) returns ClientConfigInitializationFailed? {
        self.region = amazonS3Config.region;
        if (self.region != DEFAULT_REGION) {
            var amazonHostVar = replaceFirstText(AMAZON_AWS_HOST, SERVICE_NAME, SERVICE_NAME + "." + self.region);
            if (amazonHostVar is string) {
                self.amazonHost = amazonHostVar;
            } else {
                ClientConfigInitializationFailed clientConfigInitializationFailed =
                    error(CLIENT_CONFIG_INITIALIZATION_FAILED, message = CLIENT_CONFIG_INIT_FAILED_MSG,
                          errorCode = CLIENT_CONFIG_INITIALIZATION_FAILED, cause = amazonHostVar);
                return clientConfigInitializationFailed;
            }
        } else {
            self.amazonHost = AMAZON_AWS_HOST;
        }
        string baseURL = HTTPS + self.amazonHost;
        self.accessKeyId = amazonS3Config.accessKeyId;
        self.secretAccessKey = amazonS3Config.secretAccessKey;
        check verifyCredentials(self.accessKeyId, self.secretAccessKey);
        self.amazonS3Client = new(baseURL, amazonS3Config.clientConfig);
    }

    # Retrieves a list of all Amazon S3 buckets that the authenticated user of the request owns.
    # 
    # + return - If success, returns a list of Bucket record, else returns error
    public remote function listBuckets() returns @tainted Bucket[]|ConnectorError {
        map<string> requestHeaders = {};
        http:Request request = new;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        
        SignatureGenerationError? signature = generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                                self.region, GET, SLASH,
                                                                UNSIGNED_PAYLOAD, requestHeaders);
        if (signature is SignatureGenerationError) {
            BucketListingFailed bucketListingFailed = error(BUCKET_LISTING_FAILED, message = BUCKET_LISTING_FAILED_MSG,
                                                            errorCode = BUCKET_LISTING_FAILED, cause = signature);
            return bucketListingFailed;
        } else {
            var httpResponse = self.amazonS3Client->get(SLASH, message = request);
            if (httpResponse is http:Response) {
                var amazonResponse = httpResponse.getXmlPayload();
                if (amazonResponse is xml) {
                    if (httpResponse.statusCode == http:STATUS_OK) {
                        return getBucketsList(amazonResponse);
                    } else {
                        string errorMessage = amazonResponse["Message"].getTextValue();
                        BucketListingFailed bucketListingFailed = error(BUCKET_LISTING_FAILED, message = errorMessage,
                                                                        errorCode = BUCKET_LISTING_FAILED);
                        return bucketListingFailed;
                    }
                } else {
                    HttpResponseHandlingFailed httpResponseHandlingFailed = error(HTTP_RESPONSE_HANDLING_FAILED,
                                          message = XML_EXTRACTION_ERROR_MSG, errorCode = HTTP_RESPONSE_HANDLING_FAILED,
                                          cause = amazonResponse);
                    return httpResponseHandlingFailed;
                }
            } else {
                BucketListingFailed bucketListingFailed = error(BUCKET_LISTING_FAILED,
                                    message = API_INVOCATION_ERROR_MSG, errorCode = BUCKET_LISTING_FAILED,
                                    cause = httpResponse);
                return bucketListingFailed;
            }
        }
    }

    # Create a bucket.
    # 
    # + bucketName - Unique name for the bucket to create.
    # + cannedACL - The access control list of the new bucket.
    # 
    # + return - If success, returns Status object, else returns error.
    public remote function createBucket(string bucketName, CannedACL? cannedACL = ()) returns @tainted ConnectorError? {
        map<string> requestHeaders = {};
        http:Request request = new;
        string requestURI = string `/${bucketName}/`;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        if (cannedACL != ()) {
            requestHeaders[X_AMZ_ACL] = io:sprintf("%s",cannedACL);
        }
        if(self.region != DEFAULT_REGION) {
            xml xmlPayload = xml `<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"> 
                                        <LocationConstraint>${self.region}</LocationConstraint> 
                                </CreateBucketConfiguration>`;   
            request.setXmlPayload(xmlPayload);
        }
        SignatureGenerationError? signature = generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                                self.region, PUT, requestURI,
            UNSIGNED_PAYLOAD, requestHeaders);

        if (signature is SignatureGenerationError) {
            BucketCreationFailed bucketCreationFailed = error(BUCKET_CREATION_FAILED,
                            message = BUCKET_CREATION_FAILED_MSG + bucketName, errorCode = BUCKET_CREATION_FAILED, cause = signature);
            return bucketCreationFailed;
        } else {
            var httpResponse = self.amazonS3Client->put(requestURI, request);
            if (httpResponse is http:Response) {
                var handleResponseStatus = handleResponse(httpResponse);
                if (handleResponseStatus is ServerError|HttpResponseHandlingFailed) {
                    BucketCreationFailed bucketCreationFailed = error(BUCKET_CREATION_FAILED,
                        message = <string>handleResponseStatus.detail()?.message, errorCode = BUCKET_CREATION_FAILED,
                        cause = handleResponseStatus);
                    return bucketCreationFailed;
                }
            } else {
                BucketCreationFailed bucketCreationFailed = error(BUCKET_CREATION_FAILED,
                                message = API_INVOCATION_ERROR_MSG, errorCode = BUCKET_CREATION_FAILED,
                                cause = httpResponse);
                return bucketCreationFailed;
            }
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
    # + return - If success, returns S3Object[] object, else returns error
    public remote function listObjects(string bucketName, string? delimiter = (), string? encodingType = (), 
                        int? maxKeys = (), string? prefix = (), string? startAfter = (), boolean? fetchOwner = (), 
                        string? continuationToken = ()) returns @tainted S3Object[]|ConnectorError {
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
        SignatureGenerationError? signature = generateSignature(request, self.accessKeyId, self.secretAccessKey,
                            self.region, GET, requestURI, UNSIGNED_PAYLOAD, requestHeaders, queryParams = queryParamsMap);

        if (signature is SignatureGenerationError) {
            string errorMsg = OBJECT_LISTING_FAILED_MSG + bucketName;
            ObjectListingFailed objectListingFailed = error(OBJECT_LISTING_FAILED, message = errorMsg,
                                                            errorCode = OBJECT_LISTING_FAILED, cause = signature);
            return objectListingFailed;
        } else {
            requestURI = string `${requestURI}${queryParamsStr}`;
            var httpResponse = self.amazonS3Client->get(requestURI, message = request);
            if (httpResponse is http:Response) {
                var amazonResponse = httpResponse.getXmlPayload();
                if (amazonResponse is xml) {
                    if (httpResponse.statusCode == http:STATUS_OK) {
                        return getS3ObjectsList(amazonResponse);
                    } else {
                        string errorMsg = amazonResponse["Message"].getTextValue();
                        ObjectListingFailed objectListingFailed = error(OBJECT_LISTING_FAILED, message = errorMsg,
                                                                        errorCode = OBJECT_LISTING_FAILED);
                        return objectListingFailed;
                    } 
                } else {
                    ObjectListingFailed objectListingFailed = error(OBJECT_LISTING_FAILED,
                                            message = XML_EXTRACTION_ERROR_MSG, errorCode = OBJECT_LISTING_FAILED,
                                            cause = amazonResponse);
                    return objectListingFailed;
                }
            } else {
                ObjectListingFailed objectListingFailed = error(OBJECT_LISTING_FAILED,
                                message = API_INVOCATION_ERROR_MSG, errorCode = OBJECT_LISTING_FAILED,
                                cause = httpResponse);
                return objectListingFailed;
            }
        }
    }

    # Retrieves objects from Amazon S3.
    # 
    # + bucketName - The name of the bucket.
    # + objectName - The name of the object.
    # + objectRetrievalHeaders - Optional headers for the get object function.
    # 
    # + return - If success, returns S3ObjectContent object, else returns error
    public remote function getObject(string bucketName, string objectName, 
                        ObjectRetrievalHeaders? objectRetrievalHeaders = ()) returns @tainted S3Object|ConnectorError {
        map<string> requestHeaders = {};
        http:Request request = new;
        string requestURI = string `/${bucketName}/${objectName}`;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        // Add optional headers.
        populateGetObjectHeaders(requestHeaders, objectRetrievalHeaders);
        
        SignatureGenerationError? signature = generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                                self.region, GET, requestURI,
            UNSIGNED_PAYLOAD, requestHeaders);

        if (signature is SignatureGenerationError) {
            ObjectRetrievingFailed objectRetrievingFailed = error(OBJECT_RETRIEVING_FAILED,
                                          message = OBJECT_RETRIEVING_FAILED_MSG, errorCode = OBJECT_RETRIEVING_FAILED,
                                          cause = signature);
            return objectRetrievingFailed;
        } else {
            var httpResponse = self.amazonS3Client->get(requestURI, message = request);
            if (httpResponse is http:Response) {
                if (httpResponse.statusCode == http:STATUS_OK) {
                    byte[]|error amazonResponse = extractResponsePayload(httpResponse);
                    if (amazonResponse is error) {
                        ObjectRetrievingFailed objectRetrievingFailed = error(OBJECT_RETRIEVING_FAILED,
                                           message = OBJECT_RETRIEVING_FAILED_MSG, errorCode = OBJECT_RETRIEVING_FAILED,
                                           cause = amazonResponse);
                        return objectRetrievingFailed;
                    } else {
                        return getS3Object(amazonResponse);
                    }
                } else {
                    var amazonResponse = httpResponse.getXmlPayload();
                    if (amazonResponse is xml) {
                        string errorMsg = amazonResponse["Message"].getTextValue();
                        ObjectRetrievingFailed objectRetrievingFailed = error(OBJECT_RETRIEVING_FAILED,
                                                            message = errorMsg, errorCode = OBJECT_RETRIEVING_FAILED);
                        return objectRetrievingFailed;
                    } else {
                        ObjectRetrievingFailed objectRetrievingFailed = error(OBJECT_RETRIEVING_FAILED,
                                            message = XML_EXTRACTION_ERROR_MSG, errorCode = OBJECT_RETRIEVING_FAILED);
                        return objectRetrievingFailed;
                    }    
                }     
            } else {
                ObjectRetrievingFailed objectRetrievingFailed = error(OBJECT_RETRIEVING_FAILED,
                                            message = API_INVOCATION_ERROR_MSG, errorCode = OBJECT_RETRIEVING_FAILED);
                return objectRetrievingFailed;
            }
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
    # + return - If success, returns Status object, else returns error
    public remote function createObject(string bucketName, string objectName, string|xml|json|byte[] payload, 
                        CannedACL? cannedACL = (), ObjectCreationHeaders? objectCreationHeaders = ()) 
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

        SignatureGenerationError? signature = generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                                self.region, PUT, requestURI,
            UNSIGNED_PAYLOAD, requestHeaders);
        if (signature is SignatureGenerationError) {
            ObjectCreationFailed objectCreationFailed = error(OBJECT_CREATION_FAILED,
                                               message = OBJECT_CREATION_FAILED_MSG, errorCode = OBJECT_CREATION_FAILED,
                                               cause = signature);
            return objectCreationFailed;
        } else {
            var httpResponse = self.amazonS3Client->put(requestURI, request);
            if (httpResponse is http:Response) {
                return handleResponse(httpResponse);
            } else {
                ObjectCreationFailed objectCreationFailed = error(OBJECT_CREATION_FAILED,
                                                 message = API_INVOCATION_ERROR_MSG, errorCode = OBJECT_CREATION_FAILED,
                                                 cause = httpResponse);
                return objectCreationFailed;
            }
        }
    }

    # Delete an object.
    # 
    # + bucketName - The name of the bucket.
    # + objectName - The name of the object
    # + versionId - The specific version of the object to delete, if versioning is enabled.
    # 
    # + return - If success, returns Status object, else returns error
    public remote function deleteObject(string bucketName, string objectName, string? versionId = ()) 
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
        SignatureGenerationError? signature = generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                                self.region, DELETE,
                            requestURI, UNSIGNED_PAYLOAD, requestHeaders, queryParams = queryParamsMap);

        if (signature is SignatureGenerationError) {
            ObjectDeletionFailed objectDeletionFailed = error(OBJECT_DELETION_FAILED,
                                                message = OBJECT_DELETION_FAILED_MSG, errorCode = OBJECT_DELETION_FAILED,
                                                cause = signature);
            return objectDeletionFailed;
        } else {    
            requestURI = string `${requestURI}${queryParamsStr}`;
            var httpResponse = self.amazonS3Client->delete(requestURI, request);
            if (httpResponse is http:Response) {
                return handleResponse(httpResponse);
            } else {
                ObjectDeletionFailed objectDeletionFailed = error(OBJECT_DELETION_FAILED,
                                                message = API_INVOCATION_ERROR_MSG, errorCode = OBJECT_DELETION_FAILED);
                return objectDeletionFailed;
            }
        }
    }     

    # Delete a bucket.
    # 
    # + bucketName - The name of the bucket.
    # 
    # + return - If success, returns Status object, else returns error
    public remote function deleteBucket(string bucketName) returns @tainted ConnectorError? {
        map<string> requestHeaders = {};
        http:Request request = new;
        string requestURI = string `/${bucketName}`;

        requestHeaders[HOST] = self.amazonHost;
        requestHeaders[X_AMZ_CONTENT_SHA256] = UNSIGNED_PAYLOAD;
        SignatureGenerationError? signature = generateSignature(request, self.accessKeyId, self.secretAccessKey,
                                                                self.region, DELETE,
                            requestURI, UNSIGNED_PAYLOAD, requestHeaders);

        if (signature is SignatureGenerationError) {
            BucketDeletionFailed bucketDeletionFailed = error(BUCKET_DELETION_FAILED,
                                               message = BUCKET_DELETION_FAILED_MSG, errorCode = BUCKET_DELETION_FAILED,
                                               cause = signature);
            return bucketDeletionFailed;
        } else {
            //check var or union type
            var httpResponse = self.amazonS3Client->delete(requestURI, request);
            if (httpResponse is http:Response) {
                return handleResponse(httpResponse);
            } else {
                BucketDeletionFailed bucketDeletionFailed = error(BUCKET_DELETION_FAILED,
                                                message = API_INVOCATION_ERROR_MSG, errorCode = BUCKET_DELETION_FAILED);
                return bucketDeletionFailed;
            }
        }
    }
};

# Verify the existence of credentials.
#
# + accessKeyId - The access key is of the Amazon S3 account.
# + secretAccessKey - The secret access key of the Amazon S3 account.
# 
# + return - Returns an error object if accessKeyId or secretAccessKey not exists.
function verifyCredentials(string accessKeyId, string secretAccessKey) returns error? {
    if ((accessKeyId == "") || (secretAccessKey == "")) {
        error err = error("Empty values set for accessKeyId or secretAccessKey 
                        credential", message = "Empty values set for accessKeyId or secretAccessKey 
                        credential", code = AUTH_ERROR_CODE);
        return err;
    }
}

# AmazonS3 Connector configurations can be setup here.
# + accessKeyId - The access key is of the Amazon S3 account.
# + secretAccessKey - The secret access key of the Amazon S3 account.
# + region - The AWS Region. If you don't specify an AWS region, AmazonS3Client uses US East (N. Virginia) as 
#            default region.
# + clientConfig - HTTP client config
public type ClientConfiguration record {
    string accessKeyId;
    string secretAccessKey;
    string region = DEFAULT_REGION;
    http:ClientEndpointConfig clientConfig = {http1Settings: {chunking: http:CHUNKING_NEVER}};
};
