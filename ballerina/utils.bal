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

import ballerina/crypto;
import ballerina/http;
import ballerina/jballerina.java;
import ballerina/lang.array;
import ballerina/regex;
import ballerina/time;
import ballerina/url;

isolated function generateSignature(string accessKeyId, string secretAccessKey, string region, string httpVerb, string
                            requestURI, string payload, map<string> headers, http:Request? request = (),
                            map<string>? queryParams = ()) returns @tainted error? {
    string canonicalRequest = httpVerb;
    string canonicalQueryString = "";
    string requestPayload = "";
    map<string> requestHeaders = headers;
    [string, string][amzDateStr, shortDateStr] = ["",""];

    // Generate date strings and put it in the headers map to generate the signature.
    [string, string]|error dateStrings = generateDateString();
    if (dateStrings is error) {
        return error(DATE_STRING_GENERATION_ERROR_MSG, dateStrings);
    } else {
        [amzDateStr, shortDateStr] = dateStrings;
        requestHeaders[X_AMZ_DATE] = amzDateStr;
    }

    // Get canonical URI.
    var canonicalURI = getCanonicalURI(requestURI);
    if (canonicalURI is string) {
        // Generate canonical query string.
        if (queryParams is map<string> && queryParams.length() > 0) {
            string|error canonicalQuery = generateCanonicalQueryString(queryParams);
            if (canonicalQuery is string) {
                canonicalQueryString = canonicalQuery;
            } else {
                return error(CANONICAL_QUERY_STRING_GENERATION_ERROR_MSG, canonicalQuery);
            }
        }

        // Encode request payload.
        if (payload == UNSIGNED_PAYLOAD) {
            requestPayload = payload;
        } else if (request is http:Request) {
            requestPayload = array:toBase16(crypto:hashSha256(payload.toBytes())).toLowerAscii();
            string contentType = check request.getHeader(CONTENT_TYPE.toLowerAscii()); 
            requestHeaders[CONTENT_TYPE] = contentType;
        }

        // Generete canonical and signed headers.
        [string, string] [canonicalHeaders,signedHeaders] = generateCanonicalHeaders(headers, request);

        // Generate canonical request.
        canonicalRequest = string `${canonicalRequest}${"\n"}${canonicalURI}${"\n"}${canonicalQueryString}${"\n"}`;
        canonicalRequest = string `${canonicalRequest}${canonicalHeaders}${"\n"}${signedHeaders}${"\n"}${requestPayload}`;

        // Generate string to sign.
        string stringToSign = generateStringToSign(amzDateStr, shortDateStr, region, canonicalRequest);
        // Construct authorization signature string.
        string authHeader =  check constructAuthSignature(accessKeyId, secretAccessKey, shortDateStr, region, 
            signedHeaders, stringToSign);
        // Set authorization header.
        if (request is http:Request) {
            request.setHeader(AUTHORIZATION, authHeader);
        } else {
            requestHeaders[AUTHORIZATION] = authHeader; 
        }
    } else {
        return error(CANONICAL_URI_GENERATION_ERROR_MSG, canonicalURI);
    }
}

# Funtion to generate the date strings.
#
# + return - amzDate string and short date string.
isolated function generateDateString() returns [string, string]|error {
    time:Utc time = time:utcNow();
    string amzDate = check utcToString(time, ISO8601_BASIC_DATE_FORMAT);
    string shortDate = check utcToString(time, SHORT_DATE_FORMAT);
    return [amzDate, shortDate];
}

isolated function utcToString(time:Utc utc, string pattern) returns string|error {
    [int, decimal][epochSeconds, lastSecondFraction] = utc;
    int nanoAdjustments = (<int>lastSecondFraction * 1000000000);
    var instant = ofEpochSecond(epochSeconds, nanoAdjustments);
    var zoneId = getZoneId(java:fromString("Z"));
    var zonedDateTime = atZone(instant, zoneId);
    var dateTimeFormatter = ofPattern(java:fromString(pattern));
    handle formatString = format(zonedDateTime, dateTimeFormatter);
    return formatString.toBalString();
}

# Function to generate string to sign.
#
# + amzDateStr - amzDate string.
# + shortDateStr - Short date string.
# + region - Endpoint region.x
# + canonicalRequest - Generated canonical request.
#
# + return - String to sign.
isolated function generateStringToSign(string amzDateStr, string shortDateStr, string region, string canonicalRequest)
                            returns string{
    //Start creating the string to sign
    string stringToSign = string `${AWS4_HMAC_SHA256}${"\n"}${amzDateStr}${"\n"}${shortDateStr}/${region}/${SERVICE_NAME}/${TERMINATION_STRING}${"\n"}${array:toBase16(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii()}`;
    return stringToSign;

}

# Function to get canonical URI.
#
# + requestURI - Request URI.
#
# + return - Return encoded request URI.
isolated function getCanonicalURI(string requestURI) returns string|error {
    string value = check url:encode(requestURI, UTF_8);
    return regex:replaceAll(value, ENCODED_SLASH, SLASH);
}

# Function to generate canonical query string.
#
# + queryParams - Query params map.
#
# + return - Return canonical and signed headers.
isolated function generateCanonicalQueryString(map<string> queryParams) returns string|error {
    string canonicalQueryString = "";
    string key;
    string value;
    string encodedKeyValue = EMPTY_STRING;
    string encodedValue = EMPTY_STRING;
    string[] queryParamsKeys = queryParams.keys();
    string[] sortedKeys = sort(queryParamsKeys);
    int index = 0;
    while (index < sortedKeys.length()) {
        key = sortedKeys[index];
        string encodedKey = check url:encode(key, UTF_8);
        encodedKeyValue = regex:replaceAll(encodedKey, ENCODED_SLASH, SLASH);
        value = <string>queryParams[key];
        string encodedVal = check url:encode(value, UTF_8);
        encodedValue = regex:replaceAll(encodedVal, ENCODED_SLASH, SLASH);
        canonicalQueryString = string `${canonicalQueryString}${encodedKeyValue}=${encodedValue}&`;
        index = index + 1;
    }
    canonicalQueryString = canonicalQueryString.substring(0, <int>string:lastIndexOf(canonicalQueryString, "&"));
    return canonicalQueryString;
}

# Function to generate canonical headers and signed headers and populate request headers.
#
# + headers - Headers map.
# + request - HTTP request.
# + return - Return canonical and signed headers.
isolated function generateCanonicalHeaders(map<string> headers, http:Request? request) returns @tainted[string, string] {
    string canonicalHeaders = "";
    string signedHeaders = "";
    string key;
    string value;
    string[] headerKeys = headers.keys();
    string[] sortedHeaderKeys = sort(headerKeys);
    int index = 0;
    while (index < sortedHeaderKeys.length()) {
        key = sortedHeaderKeys[index];
        value = <string>headers[key];
        if (request is http:Request) {
            request.setHeader(<@untainted>key, value);
        }
        canonicalHeaders = string `${canonicalHeaders}${key.toLowerAscii()}:${value}${"\n"}`;
        signedHeaders = string `${signedHeaders}${key.toLowerAscii()};`;
        index = index + 1;
    }
    signedHeaders = signedHeaders.substring(0, <int>string:lastIndexOf(signedHeaders, ";"));
    return [canonicalHeaders, signedHeaders];
}

# Function to generate signing key.
#
# + secretAccessKey - Value of the secret key
# + shortDateStr - shortDateStr Parameter Description
# + region - Endpoint region
# + return - Signing key
isolated function generateSigningKey(string secretAccessKey, string shortDateStr, string region) returns byte[]|error {
    string signValue = AWS4 + secretAccessKey;
    byte[] dateKey = check crypto:hmacSha256(shortDateStr.toBytes(), signValue.toBytes());
    byte[] regionKey = check crypto:hmacSha256(region.toBytes(), dateKey);
    byte[] serviceKey = check crypto:hmacSha256(SERVICE_NAME.toBytes(), regionKey);
    return crypto:hmacSha256(TERMINATION_STRING.toBytes(), serviceKey);
}

# Funtion to construct authorization header string.
#
# + accessKeyId - Value of the access key.
# + secretAccessKey - Value of the secret key.
# + shortDateStr - shortDateStr Parameter Description
# + region - Endpoint region.
# + signedHeaders - Signed headers.
# + stringToSign - stringToSign Parameter Description
# + return - Authorization header string value.
isolated function constructAuthSignature(string accessKeyId, string secretAccessKey, string shortDateStr, string region,
        string signedHeaders, string stringToSign) returns string|error {
    byte[] signingKey = check generateSigningKey(secretAccessKey, shortDateStr, region);
    string encodedStr = array:toBase16(check crypto:hmacSha256(stringToSign.toBytes(), signingKey));
    string credential = string `${accessKeyId}/${shortDateStr}/${region}/${SERVICE_NAME}/${TERMINATION_STRING}`;
    string authHeader = string `${AWS4_HMAC_SHA256} ${CREDENTIAL}=${credential},${SIGNED_HEADER}=${signedHeaders}`;
    authHeader = string `${authHeader},${SIGNATURE}=${encodedStr.toLowerAscii()}`;
    return authHeader;
}

# Function to construct signature for presigned URLs.
#
# + accessKeyId - Value of the access key  
# + secretAccessKey - Value of the secret key  
# + shortDateStr - The string representation of the current date in 'yyyyMMdd' format  
# + region - Endpoint region  
# + stringToSign - String including information such as the HTTP method, resource path, query parameters, and headers
# + return - Signature used for authentication
isolated function constructPresignedUrlSignature(string accessKeyId, string secretAccessKey, string shortDateStr, 
        string region, string stringToSign) returns string|error {
    byte[] signingKey = check generateSigningKey(secretAccessKey, shortDateStr, region);
    string encodedStr = array:toBase16(check crypto:hmacSha256(stringToSign.toBytes(), signingKey));
    return encodedStr.toLowerAscii();
}

# Function to populate createObject optional headers.
#
# + requestHeaders - Request headers map.
# + objectCreationHeaders - Optional headers for createObject function.
isolated function populateCreateObjectHeaders(map<string> requestHeaders, ObjectCreationHeaders?
                                                objectCreationHeaders) {
    if(objectCreationHeaders != ()) {
        if (objectCreationHeaders?.cacheControl != ()) {
            requestHeaders[CACHE_CONTROL] = <string>objectCreationHeaders?.cacheControl;
        }
        if (objectCreationHeaders?.contentDisposition != ()) {
            requestHeaders[CONTENT_DISPOSITION] = <string>objectCreationHeaders?.contentDisposition;
        }
        if (objectCreationHeaders?.contentEncoding != ()) {
            requestHeaders[CONTENT_ENCODING] = <string>objectCreationHeaders?.contentEncoding;
        }
        if (objectCreationHeaders?.contentLength != ()) {
            requestHeaders[CONTENT_LENGTH] = <string>objectCreationHeaders?.contentLength;
        }
        if (objectCreationHeaders?.contentMD5 != ()) {
            requestHeaders[CONTENT_MD5] = <string>objectCreationHeaders?.contentMD5;
        }
        if (objectCreationHeaders?.expect != ()) {
            requestHeaders[EXPECT] = <string>objectCreationHeaders?.expect;
        }
        if (objectCreationHeaders?.expires != ()) {
            requestHeaders[EXPIRES] = <string>objectCreationHeaders?.expires;
        }
    }
}

# Function to populate createObject optional user-defined metadata headers.
#
# + requestHeaders - Request headers map.
# + userMetadataHeaders - Map containing user-defined metadata.
isolated function populateUserMetadataHeaders(map<string> requestHeaders, map<string> userMetadataHeaders){
    foreach string metadataKey in userMetadataHeaders.keys() {
        requestHeaders["x-amz-meta-" + metadataKey.toLowerAscii()] = userMetadataHeaders[metadataKey] ?: "";
    }
}

# Function to populate getObject optional headers.
#
# + requestHeaders - Request headers map.
# + objectRetrievalHeaders - Optional headers for getObject function.
isolated function populateGetObjectHeaders(map<string> requestHeaders, ObjectRetrievalHeaders? objectRetrievalHeaders) {
    if(objectRetrievalHeaders != ()) {
        if (objectRetrievalHeaders?.modifiedSince != ()) {
            requestHeaders[IF_MODIFIED_SINCE] = <string>objectRetrievalHeaders?.modifiedSince;
        }
        if (objectRetrievalHeaders?.unModifiedSince != ()) {
            requestHeaders[IF_UNMODIFIED_SINCE] = <string>objectRetrievalHeaders?.unModifiedSince;
        }
        if (objectRetrievalHeaders?.ifMatch != ()) {
            requestHeaders[IF_MATCH] = <string>objectRetrievalHeaders?.ifMatch;
        }
        if (objectRetrievalHeaders?.ifNoneMatch != ()) {
            requestHeaders[IF_NONE_MATCH] = <string>objectRetrievalHeaders?.ifNoneMatch;
        }
        if (objectRetrievalHeaders?.range != ()) {
            requestHeaders[RANGE] = <string>objectRetrievalHeaders?.range;
        }
    }
}

isolated function populateOptionalParameters(map<string> queryParamsMap, string? delimiter = (), string? encodingType
                                                = (), int? maxKeys = (), string? prefix = (), string? startAfter = (), 
                                                boolean? fetchOwner = (), string? continuationToken = ()) returns 
                                                string {
    string queryParamsStr = "";
    // Append query parameter(delimiter).
        if (delimiter is string) {
        queryParamsStr = string `${queryParamsStr}&delimiter=${delimiter}`;
        queryParamsMap["delimiter"] = delimiter;
    }

    // Append query parameter(encoding-type).
    if (encodingType is string) {
        queryParamsStr = string `${queryParamsStr}&encoding-type=${encodingType}`;
        queryParamsMap["encoding-type"] = encodingType;
    }

    // Append query parameter(max-keys).
    if (maxKeys is int) {
        queryParamsStr = string `${queryParamsStr}&max-keys=${maxKeys}`;
        queryParamsMap["max-keys"] = maxKeys.toString();
    }

    // Append query parameter(prefix).
    if (prefix is string) {
        queryParamsStr = string `${queryParamsStr}&prefix=${prefix}`;
        queryParamsMap["prefix"] = prefix;
    }

    // Append query parameter(startAfter).
    if (startAfter is string) {
        queryParamsStr = string `${queryParamsStr}start-after=${startAfter}`;
        queryParamsMap["start-after"] = startAfter;
    }

    // Append query parameter(fetch-owner).
    if (fetchOwner is boolean) {
        queryParamsStr = string `${queryParamsStr}&fetch-owner=${fetchOwner}`;
        queryParamsMap["fetch-owner"] = fetchOwner.toString();
    }

    // Append query parameter(continuation-token).
    if (continuationToken is string) {
        queryParamsStr = string `${queryParamsStr}&continuation-token=${continuationToken}`;
        queryParamsMap["continuation-token"] = continuationToken;
    }
    return queryParamsStr;
}

isolated function handleHttpResponse(http:Response httpResponse) returns @tainted error? {
    int statusCode = httpResponse.statusCode;
    if (statusCode != http:STATUS_OK && statusCode != http:STATUS_NO_CONTENT) {
        xml xmlPayload = check httpResponse.getXmlPayload();
        return error(xmlPayload.toString());
    }
}
