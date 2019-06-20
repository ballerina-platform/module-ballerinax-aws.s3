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

import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/system;
import ballerina/time;
import ballerina/io;

function generateSignature(http:Request request, string accessKeyId, string secretAccessKey, string region,
                           string httpVerb, string requestURI, string payload, map<anydata> headers, 
                           map<anydata>? queryParams = ()) returns error? {

    string canonicalRequest = httpVerb;
    string canonicalQueryString = "";
    string requestPayload = "";
    map<anydata> requestHeaders = headers;

    // Generate date strings and put it in the headers map to generate the signature.
    (string, string)(amzDateStr, shortDateStr) = generateDateString();
    requestHeaders[X_AMZ_DATE] = amzDateStr;

    // Get canonical URI.
    string canonicalURI = getCanonicalURI(requestURI);

        // Generate canonical query string.
    if (queryParams is map<anydata> && queryParams.length() > 0) {
        canonicalQueryString = generateCanonicalQueryString(queryParams);
    }

    // Encode request payload.
    if (payload == UNSIGNED_PAYLOAD) {
        requestPayload = payload;
    } else {
        requestPayload = encoding:encodeHex(crypto:hashSha256(payload.toByteArray(UTF_8))).toLower();
        requestHeaders[CONTENT_TYPE] = request.getHeader(CONTENT_TYPE.toLower());
    }

    // Generete canonical and signed headers.
    (string, string) (canonicalHeaders,signedHeaders) = generateCanonicalHeaders(headers, request);

    // Generate canonical request.
    canonicalRequest = string `${canonicalRequest}\n${canonicalURI}\n${canonicalQueryString}\n`;
    canonicalRequest = string `${canonicalRequest}${canonicalHeaders}\n${signedHeaders}\n${requestPayload}`;

    // Generate string to sign.
    string stringToSign = generateStringToSign(amzDateStr, shortDateStr,region, canonicalRequest);
    
    // Construct authorization signature string.
    string authHeader = constructAuthSignature(accessKeyId, secretAccessKey, shortDateStr, region, signedHeaders, 
                            stringToSign);
    // Set authorization header.
    request.setHeader(AUTHORIZATION, authHeader);
}

function setResponseError(string errorMessage) returns error {
    error err = error(AMAZONS3_ERROR_CODE, { message : errorMessage });
    return err;
}

# Funtion to generate the date strings.
# 
# + return - amzDate string and short date string.
function generateDateString() returns (string, string) {
    time:Time|error time = time:toTimeZone(time:currentTime(), "GMT");
    string amzDateStr;
    string shortDateStr;
    if (time is time:Time) {
        string|error amzDate = time:format(time, ISO8601_BASIC_DATE_FORMAT);
        string|error shortDate = time:format(time, SHORT_DATE_FORMAT);
        if (amzDate is string) {
            amzDateStr = amzDate;

        } else {
            panic amzDate;
        }
        if (shortDate is string) {
            shortDateStr = shortDate;
        } else {
            panic shortDate;
        }
    } else {
        panic time;
    }
    return (amzDateStr, shortDateStr);
}

# Function to generate string to sign.
# 
# + amzDateStr - amzDate string.
# + shortDateStr - Short date string.
# + region - Endpoint region.
# + canonicalRequest - Generated canonical request.
# 
# + return - String to sign.
function generateStringToSign(string amzDateStr, string shortDateStr, string region, string canonicalRequest) 
                            returns string{
    //Start creating the string to sign
    string stringToSign = string `${AWS4_HMAC_SHA256}\n${amzDateStr}\n${shortDateStr}`;
    stringToSign = string `${stringToSign}/${region}/${SERVICE_NAME}/${TERMINATION_STRING}\n`;
    stringToSign = stringToSign + encoding:encodeHex(crypto:hashSha256(canonicalRequest.toByteArray(UTF_8))).toLower();
    return stringToSign;

}

# Function to get canonical URI.
#
# + requestURI - Request URI. 
# 
# + return - Return encoded request URI.
function getCanonicalURI(string requestURI) returns string {
    string encodedrequestURIValue;
    var value = http:encode(requestURI, UTF_8);
    if (value is string) {
        encodedrequestURIValue = value.replace("%2F", "/");
    } else {
        error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred when converting to string"});
        panic err;
    }
    return encodedrequestURIValue;
}

# Function to generate canonical query string.
#
# + queryParams - Query params map. 
# 
# + return - Return canonical and signed headers.
function generateCanonicalQueryString(map<anydata> queryParams) returns string {
    string canonicalQueryString = "";
    string key;
    string value;
    string encodedKeyValue;
    string encodedValue;
    string[] queryParamsKeys = queryParams.keys();
    string[] sortedKeys = sort(queryParamsKeys);
    int index = 0;
    while (index < sortedKeys.length()) {
        key = sortedKeys[index];
        var encodedKey = http:encode(key, UTF_8);
        if (encodedKey is string) {
            encodedKeyValue = encodedKey.replace("%2F", "/");
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred when converting to string"});
            panic err;
        }
        value = <string>queryParams[key];
        var encodedVal = http:encode(value, UTF_8);
        if (encodedVal is string) {
            encodedValue = encodedVal.replace("%2F", "/");
        } else {
            error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred when converting to string"});
            panic err;
        }
        canonicalQueryString = string `${canonicalQueryString}${encodedKeyValue}=${encodedValue}&`;
        index = index + 1;
    }
    canonicalQueryString = canonicalQueryString.substring(0,canonicalQueryString.lastIndexOf("&"));

    return canonicalQueryString;
}

# Function to generate canonical headers and signed headers and populate request headers.
#
# + headers - Headers map. 
# + request - HTTP request.
# 
# + return - Return canonical and signed headers.
function generateCanonicalHeaders(map<anydata> headers, http:Request request) returns (string, string) {
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
        request.setHeader(key, value);
        canonicalHeaders = string `${canonicalHeaders}${key.toLower()}:${value}\n`;
        signedHeaders = string `${signedHeaders}${key.toLower()};`;
        index = index + 1;
    }
    signedHeaders = signedHeaders.substring(0,signedHeaders.lastIndexOf(";"));
    return (canonicalHeaders, signedHeaders);
}

# Funtion to construct authorization header string.
#
# + accessKeyId - Value of the access key.  
# + secretAccessKey - Value of the secret key. 
# + shortDateStr - shortDateStr Parameter Description 
# + region - Endpoint region.
# + signedHeaders - Signed headers.
# + stringToSign - stringToSign Parameter Description 
# 
# + return - Authorization header string value.
function constructAuthSignature(string accessKeyId, string secretAccessKey, string shortDateStr, string region, 
                                string signedHeaders, string stringToSign) returns string{
    string signValue = (AWS4 + secretAccessKey);
    byte[] dateKey = crypto:hmacSha256(shortDateStr.toByteArray(UTF_8), signValue.toByteArray(UTF_8));
    byte[] regionKey = crypto:hmacSha256(region.toByteArray(UTF_8), dateKey);
    byte[] serviceKey = crypto:hmacSha256(SERVICE_NAME.toByteArray(UTF_8), regionKey);
    byte[] signingKey = crypto:hmacSha256(TERMINATION_STRING.toByteArray(UTF_8), serviceKey);

    string encodedStr = encoding:encodeHex(crypto:hmacSha256(stringToSign.toByteArray(UTF_8), signingKey));
    string credential = string `${accessKeyId}/${shortDateStr}/${region}/${SERVICE_NAME}/${TERMINATION_STRING}`;     
    string authHeader = string `${AWS4_HMAC_SHA256} ${CREDENTIAL}=${credential},${SIGNED_HEADER}=${signedHeaders}`;
    authHeader = string `${authHeader},${SIGNATURE}=${encodedStr.toLower()}`;

    return authHeader;
}

# Function to populate createObject optional headers.
# 
# + requestHeaders - Request headers map.
# + createObjectHeaders - Optional headers for createObject function.
function populateCreateObjectHeaders(map<anydata> requestHeaders, CreateObjectHeaders? createObjectHeaders) {
    if(createObjectHeaders != ()) {
        if (createObjectHeaders.cacheControl != ()) {
            requestHeaders[CACHE_CONTROL] = <string>createObjectHeaders.cacheControl;
        }
        if (createObjectHeaders.contentDisposition != ()) {
            requestHeaders[CONTENT_DISPOSITION] = <string>createObjectHeaders.contentDisposition;
        }
        if (createObjectHeaders.contentEncoding != ()) {
            requestHeaders[CONTENT_ENCODING] = <string>createObjectHeaders.contentEncoding;
        }
        if (createObjectHeaders.contentLength != ()) {
            requestHeaders[CONTENT_LENGTH] = <string>createObjectHeaders.contentLength;
        }
        if (createObjectHeaders.contentMD5 != ()) {
            requestHeaders[CONTENT_MD5] = <string>createObjectHeaders.contentMD5;
        }
        if (createObjectHeaders.expect != ()) {
            requestHeaders[EXPECT] = <string>createObjectHeaders.expect;
        }
        if (createObjectHeaders.expires != ()) {
            requestHeaders[EXPIRES] = <string>createObjectHeaders.expires;
        }
    }
}

# Function to populate getObject optional headers.
# 
# + requestHeaders - Request headers map.
# + getObjectHeaders - Optional headers for getObject function.
function populateGetObjectHeaders(map<anydata> requestHeaders, GetObjectHeaders? getObjectHeaders) {
    if(getObjectHeaders != ()) {
        if (getObjectHeaders.modifiedSince != ()) {
            requestHeaders[IF_MODIFIED_SINCE] = <string>getObjectHeaders.modifiedSince;
        }
        if (getObjectHeaders.unModifiedSince != ()) {
            requestHeaders[IF_UNMODIFIED_SINCE] = <string>getObjectHeaders.unModifiedSince;
        }
        if (getObjectHeaders.ifMatch != ()) {
            requestHeaders[IF_MATCH] = <string>getObjectHeaders.ifMatch;
        }
        if (getObjectHeaders.ifNoneMatch != ()) {
            requestHeaders[IF_NONE_MATCH] = <string>getObjectHeaders.ifNoneMatch;
        }
        if (getObjectHeaders.range != ()) {
            requestHeaders[RANGE] = <string>getObjectHeaders.range;
        }
    }
}

function populateOptionalParameters(string? delimiter = (), string? encodingType = (), int? maxKeys = (), 
                    string? prefix = (), string? startAfter = (), boolean? fetchOwner = (), 
                    string? continuationToken = (), map<anydata> queryParamsMap) returns string {
    string queryParamsStr = "";
    // Append query parameter(delimiter).
    var delimiterStr = delimiter;
    if (delimiterStr is string) {
        queryParamsStr = string `${queryParamsStr}&delimiter=${delimiterStr}`;
        queryParamsMap["delimiter"] = delimiterStr;
    } 

    // Append query parameter(encoding-type).
    var encodingTypeStr = encodingType;
    if (encodingTypeStr is string) {
        queryParamsStr = string `${queryParamsStr}&encoding-type=${encodingTypeStr}`;
        queryParamsMap["encoding-type"] = encodingTypeStr;
    } 

    // Append query parameter(max-keys).
    var maxKeysVal = maxKeys;
    if (maxKeysVal is int) {
        queryParamsStr = string `${queryParamsStr}&max-keys=${maxKeysVal}`;
        //Check string.convert()
        queryParamsMap["max-keys"] = io:sprintf("%s", maxKeysVal);
    } 

    // Append query parameter(prefix).
    var prefixStr = prefix;
    if (prefixStr is string) {
        queryParamsStr = string `${queryParamsStr}&prefix=${prefixStr}`;
        queryParamsMap["prefix"] = prefixStr;
    }  

    // Append query parameter(startAfter).
    var startAfterStr = startAfter;
    if (startAfterStr is string) {
        queryParamsStr = string `${queryParamsStr}start-after=${startAfterStr}`;
        queryParamsMap["start-after"] = prefixStr;
    }  

    // Append query parameter(fetch-owner).
    var fetchOwnerBool = fetchOwner;
    if (fetchOwnerBool is boolean) {
        queryParamsStr = string `${queryParamsStr}&fetch-owner=${fetchOwnerBool}`;
        queryParamsMap["fetch-owner"] = io:sprintf("%s", fetchOwnerBool);
    }  

    // Append query parameter(continuation-token).
    var continuationTokenStr = continuationToken;
    if (continuationTokenStr is string) {
        queryParamsStr = string `${queryParamsStr}&continuation-token=${continuationTokenStr}`;
        queryParamsMap["continuation-token"] = continuationTokenStr;
    } 
    return queryParamsStr;
}

function handleResponse(http:Response httpResponse) returns boolean|error {
    int statusCode = httpResponse.statusCode;
    if (statusCode == 200 || statusCode == 204) {
        return true;
    } else {
        var amazonResponse = httpResponse.getXmlPayload();
        if (amazonResponse is xml) {
            return setResponseError(amazonResponse["Message"].getTextValue());
        } else {
            return setResponseError(XML_EXTRACTION_ERROR_MSG);
        }
    }
}