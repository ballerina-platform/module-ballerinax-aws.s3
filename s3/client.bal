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
import ballerina/regex;
import ballerinax/'client.config;

# Ballerina Amazon S3 connector provides the capability to access AWS S3 API.
# This connector lets you to get authorized access to AWS S3 buckets and objects.
#
@display {label: "Amazon S3", iconPath: "icon.png"}
public isolated client class Client {
    private final string accessKeyId;
    private final string secretAccessKey;
    private final string region;
    private final string amazonHost;
    private final http:Client amazonS3;

    # Initializes the connector. During initialization you have to pass access key id and secret access key
    # Create an AWS account and obtain tokens following
    # [this guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
    #
    # + amazonS3Config - Configuration required to initialize the client
    # + httpConfig - HTTP configuration
    # + return - An error on failure of initialization or else `()`
    public isolated function init(ConnectionConfig config) returns error? {
        self.region = (config?.region is string) ? <string>(config?.region) : DEFAULT_REGION;
        self.amazonHost = self.region != DEFAULT_REGION ? regex:replaceFirst(AMAZON_AWS_HOST, SERVICE_NAME,
            SERVICE_NAME + "." + self.region) : AMAZON_AWS_HOST;
        string baseURL = HTTPS + self.amazonHost;
        self.accessKeyId = config.accessKeyId;
        self.secretAccessKey = config.secretAccessKey;
        check verifyCredentials(self.accessKeyId, self.secretAccessKey);

        http:ClientConfiguration httpClientConfig = check config:constructHTTPClientConfig(config);
        httpClientConfig.http1Settings = {chunking: http:CHUNKING_NEVER};
        self.amazonS3 = check new (baseURL, httpClientConfig);
    }

    # Retrieves a list of all Amazon S3 buckets that the authenticated user of the request owns.
    #
    # + return - If success, a list of Bucket record, else an error
    @display {label: "List Buckets"}
    remote isolated function listBuckets() returns @tainted Bucket[]|error {
        map<string> requestHeaders = setDefaultHeaders(self.amazonHost);
        check generateSignature(self.accessKeyId, self.secretAccessKey, self.region, GET, SLASH, UNSIGNED_PAYLOAD,
            requestHeaders);
        http:Response httpResponse = check self.amazonS3->get(SLASH, requestHeaders);
        xml xmlPayload = check httpResponse.getXmlPayload();
        if (httpResponse.statusCode == http:STATUS_OK) {
            return getBucketsList(xmlPayload);
        }
        return error(xmlPayload.toString());
    }

    # Creates a bucket.
    #
    # + bucketName - A unique name for the bucket
    # + cannedACL - The access control list of the new bucket
    # + return - An error on failure or else `()`
    @display {label: "Create Bucket"}
    remote isolated function createBucket(@display {label: "Bucket Name"} string bucketName,
            @display {label: "Access Control List"} CannedACL? cannedACL = ()) returns
                                    @tainted error? {
        http:Request request = new;
        string requestURI = string `/${bucketName}/`;
        map<string> requestHeaders = setDefaultHeaders(self.amazonHost);
        if (cannedACL != ()) {
            requestHeaders[X_AMZ_ACL] = cannedACL.toString();
        }
        if (self.region != DEFAULT_REGION) {
            xml xmlPayload = xml `<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"> 
                                        <LocationConstraint>${self.region}</LocationConstraint> 
                                </CreateBucketConfiguration>`;
            request.setXmlPayload(xmlPayload);
        }

        check generateSignature(self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI, UNSIGNED_PAYLOAD,
            requestHeaders, request);
        http:Response httpResponse = check self.amazonS3->put(requestURI, request);
        return handleHttpResponse(httpResponse);
    }

    # Retrieves the existing objects in a given bucket.
    #
    # + bucketName - The name of the bucket
    # + delimiter - A delimiter is a character you use to group keys
    # + encodingType - The encoding method to be applied to the response
    # + maxKeys - The maximum number of keys to include in the response
    # + prefix - The prefix of the objects to be listed. If unspecified, all objects are listed
    # + startAfter - Object key from which to begin listing
    # + fetchOwner - Set to true, to retrieve the owner information in the response. By default the API does not return
    # the Owner information in the response
    # + continuationToken - When the response to this API call is truncated (that is, the IsTruncated response element 
    # value is true), the response also includes the NextContinuationToken element. 
    # To list the next set of objects, you can use the NextContinuationToken element in the next 
    # request as the continuation-token
    # + return - If success, list of S3 objects, else an error
    @display {label: "List Objects"}
    remote isolated function listObjects(@display {label: "Bucket Name"} string bucketName,
            @display {label: "Group Identifier"} string? delimiter = (),
            @display {label: "Encoding Type"} string? encodingType = (),
            @display {label: "Maximum Number of Keys"} int? maxKeys = (),
            @display {label: "Required Object Prefix"} string? prefix = (),
            @display {label: "Object Key Starts From"} string? startAfter = (),
            @display {label: "Is Owner Information Required?"} boolean? fetchOwner = (),
            @display {label: "Next List Token"} string? continuationToken = ()) returns @tainted
                                @display {label: "List of Objects"} S3Object[]|error {
        map<string> queryParamsMap = {};
        string requestURI = string `/${bucketName}/`;
        string queryParamsStr = "?list-type=2";
        queryParamsMap["list-type"] = "2";
        string queryParams = populateOptionalParameters(queryParamsMap, delimiter = delimiter, encodingType =
            encodingType, maxKeys = maxKeys, prefix = prefix, startAfter = startAfter, fetchOwner = fetchOwner,
            continuationToken = continuationToken);
        queryParamsStr = string `${queryParamsStr}${queryParams}`;
        map<string> requestHeaders = setDefaultHeaders(self.amazonHost);

        check generateSignature(self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD,
            requestHeaders, queryParams = queryParamsMap);
        requestURI = string `${requestURI}${queryParamsStr}`;
        http:Response httpResponse = check self.amazonS3->get(requestURI, requestHeaders);
        xml xmlPayload = check httpResponse.getXmlPayload();
        if (httpResponse.statusCode == http:STATUS_OK) {
            return getS3ObjectsList(xmlPayload);
        }
        return error(xmlPayload.toString());
    }

    # Retrieves objects from Amazon S3.
    #
    # + bucketName - The name of the bucket
    # + objectName - The name of the object
    # + objectRetrievalHeaders - Optional headers for the get object
    # + byteArraySize - A defaultable parameter to state the size of the byte array. Default size is 8KB
    # + return - If success, S3ObjectContent object, else an error
    @display {label: "Get Object"}
    remote isolated function getObject(@display {label: "Bucket Name"} string bucketName,
            @display {label: "Object Name"} string objectName,
            @display {label: "Object Retrieval Headers"} ObjectRetrievalHeaders?
                                objectRetrievalHeaders = (),
            @display {label: "Byte Array Size"} int? byteArraySize = ())
                                returns @tainted@display {label: "Byte Stream"} stream<byte[], io:Error?>|error {
        string requestURI = string `/${bucketName}/${objectName}`;
        map<string> requestHeaders = setDefaultHeaders(self.amazonHost);

        // Add optional headers.
        populateGetObjectHeaders(requestHeaders, objectRetrievalHeaders);

        check generateSignature(self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, UNSIGNED_PAYLOAD,
            requestHeaders);
        http:Response httpResponse = check self.amazonS3->get(requestURI, requestHeaders);
        if (httpResponse.statusCode == http:STATUS_OK || (httpResponse.statusCode == http:STATUS_PARTIAL_CONTENT && objectRetrievalHeaders?.range != ())) {
            if byteArraySize is int {
                return httpResponse.getByteStream(byteArraySize);
            }
            return httpResponse.getByteStream();
        } else {
            xml xmlPayload = check httpResponse.getXmlPayload();
            return error(xmlPayload.toString());
        }
    }

    # Creates an object.
    #
    # + bucketName - The name of the bucket
    # + objectName - The name of the object
    # + payload - The file content that needed to be added to the bucket
    # + cannedACL - The access control list of the new object
    # + objectCreationHeaders - Optional headers for the `createObject` function
    # + userMetadataHeaders - Optional headers to add user-defined metadata
    # + return - An error on failure or else `()`
    @display {label: "Create Object"}
    remote isolated function createObject(@display {label: "Bucket Name"} string bucketName,
                                    @display {label: "Object Name"} string objectName,
                                    @display {label: "File Content"} string|xml|json|byte[]|stream<io:Block, io:Error?> payload,
                                    @display {label: "Grant"} CannedACL? cannedACL = (),
                                    @display {label: "Object Creation Headers"} ObjectCreationHeaders? objectCreationHeaders = (), 
                                    @display {label: "User Metadata Headers"} map<string> userMetadataHeaders = {}) 
                                    returns error? {
        http:Request request = new;
        string requestURI = string `/${bucketName}/${objectName}`;
        map<string> requestHeaders = setDefaultHeaders(self.amazonHost);
        if payload is byte[] {
            request.setBinaryPayload(payload);
        } else if payload is stream<io:Block, io:Error?> {
            request.setByteStream(payload);
        } else {
            request.setPayload(payload);
        }

        // Add optional headers.
        populateCreateObjectHeaders(requestHeaders, objectCreationHeaders);

        // Add user-defined metadata headers.
        populateUserMetadataHeaders(requestHeaders, userMetadataHeaders);
        
        check generateSignature(self.accessKeyId, self.secretAccessKey, self.region, PUT, requestURI, UNSIGNED_PAYLOAD,
            requestHeaders, request);
        http:Response httpResponse = check self.amazonS3->put(requestURI, request);
        return handleHttpResponse(httpResponse);
    }

    # Deletes an object.
    #
    # + bucketName - The name of the bucket
    # + objectName - The name of the object
    # + versionId - The specific version of the object to delete, if versioning is enabled
    # + return - An error on failure or else `()`
    @display {label: "Delete Object"}
    remote isolated function deleteObject(@display {label: "Bucket Name"} string bucketName,
            @display {label: "Object Name"} string objectName,
            @display {label: "Object Version"} string? versionId = ())
                                    returns @tainted error? {
        map<string> queryParamsMap = {};
        http:Request request = new;
        string queryParamsStr = "";
        string requestURI = string `/${bucketName}/${objectName}`;

        // Append query parameter(versionId).
        if (versionId is string) {
            queryParamsStr = string `${queryParamsStr}?versionId=${versionId}`;
            queryParamsMap["versionId"] = versionId;
        }
        map<string> requestHeaders = setDefaultHeaders(self.amazonHost);

        check generateSignature(self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
            UNSIGNED_PAYLOAD, requestHeaders, request, queryParams = queryParamsMap);
        requestURI = string `${requestURI}${queryParamsStr}`;
        http:Response httpResponse = check self.amazonS3->delete(requestURI, request);
        return handleHttpResponse(httpResponse);
    }

    # Deletes a bucket.
    #
    # + bucketName - The name of the bucket
    # + return - An error on failure or else `()`
    @display {label: "Delete Bucket"}
    remote isolated function deleteBucket(@display {label: "Bucket Name"} string bucketName) returns @tainted error? {
        http:Request request = new;
        string requestURI = string `/${bucketName}`;
        map<string> requestHeaders = setDefaultHeaders(self.amazonHost);

        check generateSignature(self.accessKeyId, self.secretAccessKey, self.region, DELETE, requestURI,
            UNSIGNED_PAYLOAD, requestHeaders, request);
        http:Response httpResponse = check self.amazonS3->delete(requestURI, request);
        return handleHttpResponse(httpResponse);
    }

    # Generates a presigned URL for the object.
    #
    # + bucketName - The name of the bucket  
    # + objectName - The name of the object  
    # + expirationTime - The time until the presigned URL is valid  
    # + httpMethod - The HTTP method to be used, either GET or PUT  
    # + partNo - The part number of the object, when uploading multipart objects
    # + uploadId - The upload ID of the multipart upload
    # + return - If success, a presigned URL, else an error
    @display {label: "Create Presigned URL"}
    remote isolated function createPresignedURL(@display {label: "Bucket Name"} string bucketName,
        @display {label: "Object Name"} string objectName,
        @display {label: "HTTP Method"} string httpMethod,
        @display {label: "Expiration Time"} int expirationTime = 3600,
        @display {label: "Part Number"} int partNo = 0,
        @display {label: "Upload ID"} string? uploadId = ()) returns string|error? {
        [string, string] [amzDateStr, shortDateStr] = ["", ""];
        [string, string]|error result = generateDateString();
        if result is error {
            return error("Error occurred while generating date string", result);
        }
        [amzDateStr, shortDateStr] = result;
        map<string> queryParams = {
            [X_AMZ_ALGORITHM] : AWS4_HMAC_SHA256,
            [X_AMZ_CREDENTIAL] : string `${self.accessKeyId}/${shortDateStr}/${self.region}/${SERVICE_NAME}/${TERMINATION_STRING}`,
            [X_AMZ_DATE] : amzDateStr,
            [X_AMZ_EXPIRES] : expirationTime.toString(),
            [X_AMZ_SIGNED_HEADERS] : HOST_LOWERCASE
        };

        string canonicalURI = string `/${objectName}`;
        string canonicalQueryString = EMPTY_STRING;

        string|error canonicalQuery = generateCanonicalQueryString(queryParams);
        if canonicalQuery is error {
                return error(CANONICAL_QUERY_STRING_GENERATION_ERROR_MSG, canonicalQuery);
        } 
        canonicalQueryString = canonicalQuery;

        if partNo != 0 && uploadId != () && httpMethod == PUT {
            canonicalQueryString = string `${canonicalQueryString}&partNumber=${partNo}&uploadId=${uploadId}`;
        }
        // Replace '/' with '%2F' in the canonical query string.
        string:RegExp r = re `/`;
        canonicalQueryString = r.replaceAll(canonicalQueryString, "%2F");
        string canonicalHeaders = string `${HOST_LOWERCASE}:${bucketName}.${self.amazonHost}`;
        string signedHeaders = HOST_LOWERCASE;
        string canonicalRequest = string `${httpMethod}${"\n"}${canonicalURI}${"\n"}${canonicalQueryString}${"\n"}${canonicalHeaders}${"\n"}${"\n"}${signedHeaders}${"\n"}${UNSIGNED_PAYLOAD}`;

        // Generate the string to sign
        string stringToSign = generateStringToSign(amzDateStr, shortDateStr, self.region, canonicalRequest);
        string signature = check constructPresignSignature(self.accessKeyId, self.secretAccessKey, shortDateStr, self.region,
        signedHeaders, stringToSign);
        return string `${HTTPS}${bucketName}.${self.amazonHost}/${objectName}?${canonicalQueryString}&${X_AMZ_SIGNATURE}=${signature}`;
    }
}

isolated function setDefaultHeaders(string amazonHost) returns map<string> {
    map<string> requestHeaders = {
        [HOST] : amazonHost,
        [X_AMZ_CONTENT_SHA256] : UNSIGNED_PAYLOAD
    };
    return requestHeaders;
}

# Verifies the existence of credentials.
#
# + accessKeyId - The access key of the Amazon S3 account
# + secretAccessKey - The secret access key of the Amazon S3 account
#
# + return - An error on failure or else `()`
isolated function verifyCredentials(string accessKeyId, string secretAccessKey) returns error? {
    if ((accessKeyId == "") || (secretAccessKey == "")) {
        return error(EMPTY_VALUES_FOR_CREDENTIALS_ERROR_MSG);
    }
}
