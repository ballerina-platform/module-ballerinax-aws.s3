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
import ballerina/encoding;
import ballerina/http;
import ballerina/system;
import ballerina/time;
import ballerinax/java;

function generateSignature(http:Request request, string accessKeyId, string secretAccessKey, string region,
                           string httpVerb, string requestURI, string payload, map<string> headers,
                           map<string>? queryParams = ()) returns error? {

    string canonicalRequest = httpVerb;
    string canonicalQueryString = "";
    string requestPayload = "";
    map<string> requestHeaders = headers;

    // Generate date strings and put it in the headers map to generate the signature.
    [string, string][amzDateStr, shortDateStr] = generateDateString();
    requestHeaders[X_AMZ_DATE] = amzDateStr;

    // Get canonical URI.
    var canonicalURI = getCanonicalURI(requestURI);
    if (canonicalURI is string) {
        // Generate canonical query string.
        if (queryParams is map<string> && queryParams.length() > 0) {
            canonicalQueryString = generateCanonicalQueryString(queryParams);
        }

        // Encode request payload.
        if (payload == UNSIGNED_PAYLOAD) {
            requestPayload = payload;
        } else {
            requestPayload = encoding:encodeHex(crypto:hashSha256(payload.toBytes())).toLowerAscii();
            requestHeaders[CONTENT_TYPE] = request.getHeader(CONTENT_TYPE.toLowerAscii());
        }

        // Generete canonical and signed headers.
        [string, string] [canonicalHeaders,signedHeaders] = generateCanonicalHeaders(headers, request);

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
        
    } else {
        return setResponseError(SIGNATURE_GENEREATION_ERROR);
    }
    //var canonicalURI = getCanonicalURI(requestURI);


    
}

function setResponseError(string errorMessage) returns error {
    return error(message = errorMessage, code = AMAZONS3_ERROR_CODE);
}

# Funtion to generate the date strings.
#
# + return - amzDate string and short date string.
function generateDateString() returns [string, string] {
    time:Time time = checkpanic time:toTimeZone(time:currentTime(), "GMT");
    string amzDate = checkpanic time:format(time, ISO8601_BASIC_DATE_FORMAT);
    string shortDate = checkpanic time:format(time, SHORT_DATE_FORMAT);
    return [amzDate, shortDate];
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
    string stringToSign = string `${AWS4_HMAC_SHA256}\n${amzDateStr}\n${shortDateStr}/${region}/${SERVICE_NAME}/${TERMINATION_STRING}\n${encoding:encodeHex(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii()}`;
    // stringToSign = stringToSign + encoding:encodeHex(crypto:hashSha256(canonicalRequest.toByteArray(UTF_8))).toLower();
    return stringToSign;

}

# Function to get canonical URI.
#
# + requestURI - Request URI.
#
# + return - Return encoded request URI.
function getCanonicalURI(string requestURI) returns string|error {
    string value = checkpanic http:encode(requestURI, UTF_8);
    return replaceText(value, ENCODED_SLASH, SLASH);
    //return value.replace(ENCODED_SLASH, SLASH);
}

# Function to generate canonical query string.
#
# + queryParams - Query params map.
#
# + return - Return canonical and signed headers.
function generateCanonicalQueryString(map<string> queryParams) returns string {
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
        var encodedKey = http:encode(key, UTF_8);
        if (encodedKey is string) {
            var encodedKeyValueVar = replaceText(encodedKey, ENCODED_SLASH, SLASH);
            if (encodedKeyValueVar is string) {
                encodedKeyValue = encodedKeyValueVar;
            }
        } else {
            panic error(message = "Error occurred when converting to string", code = AMAZONS3_ERROR_CODE);
        }
        value = <string>queryParams[key];
        var encodedVal = http:encode(value, UTF_8);
        if (encodedVal is string) {
            var encodedValueVar = replaceText(encodedVal, ENCODED_SLASH, SLASH);
            if (encodedValueVar is string) {
                encodedValue = encodedValueVar;
            }
            //encodedValue = encodedVal.replace(ENCODED_SLASH, SLASH);
        } else {
            panic error(message = "Error occurred when converting to string", code = AMAZONS3_ERROR_CODE);
        }
        canonicalQueryString = string `${canonicalQueryString}${encodedKeyValue}=${encodedValue}&`;
        index = index + 1;
    }
    canonicalQueryString = canonicalQueryString.substring(0,getLastIndexOf(canonicalQueryString, "&"));

    return canonicalQueryString;
}

# Function to generate canonical headers and signed headers and populate request headers.
#
# + headers - Headers map.
# + request - HTTP request.
#
# + return - Return canonical and signed headers.
function generateCanonicalHeaders(map<string> headers, http:Request request) returns [string, string] {
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
        canonicalHeaders = string `${canonicalHeaders}${key.toLowerAscii()}:${value}\n`;
        signedHeaders = string `${signedHeaders}${key.toLowerAscii()};`;
        index = index + 1;
    }
    signedHeaders = signedHeaders.substring(0, getLastIndexOf(signedHeaders, ";"));
    return [canonicalHeaders, signedHeaders];
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
                                string signedHeaders, string stringToSign) returns string {
    string signValue = AWS4 + secretAccessKey;
    byte[] dateKey = crypto:hmacSha256(shortDateStr.toBytes(), signValue.toBytes());
    byte[] regionKey = crypto:hmacSha256(region.toBytes(), dateKey);
    byte[] serviceKey = crypto:hmacSha256(SERVICE_NAME.toBytes(), regionKey);
    byte[] signingKey = crypto:hmacSha256(TERMINATION_STRING.toBytes(), serviceKey);

    string encodedStr = encoding:encodeHex(crypto:hmacSha256(stringToSign.toBytes(), signingKey));
    string credential = string `${accessKeyId}/${shortDateStr}/${region}/${SERVICE_NAME}/${TERMINATION_STRING}`;
    string authHeader = string `${AWS4_HMAC_SHA256} ${CREDENTIAL}=${credential},${SIGNED_HEADER}=${signedHeaders}`;
    authHeader = string `${authHeader},${SIGNATURE}=${encodedStr.toLowerAscii()}`;

    return authHeader;
}

# Function to populate createObject optional headers.
#
# + requestHeaders - Request headers map.
# + objectCreationHeaders - Optional headers for createObject function.
function populateCreateObjectHeaders(map<string> requestHeaders, ObjectCreationHeaders? objectCreationHeaders) {
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

# Function to populate getObject optional headers.
#
# + requestHeaders - Request headers map.
# + objectRetrievalHeaders - Optional headers for getObject function.
function populateGetObjectHeaders(map<string> requestHeaders, ObjectRetrievalHeaders? objectRetrievalHeaders) {
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

function populateOptionalParameters(map<string> queryParamsMap, string? delimiter = (), string? encodingType = (), int? maxKeys = (),
                    string? prefix = (), string? startAfter = (), boolean? fetchOwner = (),
                    string? continuationToken = ()) returns string {
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
        queryParamsMap["max-keys"] = io:sprintf("%s", maxKeys);
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
        queryParamsMap["fetch-owner"] = io:sprintf("%s", fetchOwner);
    }

    // Append query parameter(continuation-token).
    if (continuationToken is string) {
        queryParamsStr = string `${queryParamsStr}&continuation-token=${continuationToken}`;
        queryParamsMap["continuation-token"] = continuationToken;
    }
    return queryParamsStr;
}

function handleResponse(http:Response httpResponse) returns @tainted error? {
    int statusCode = httpResponse.statusCode;
    if (statusCode != http:STATUS_OK && statusCode != http:STATUS_NO_CONTENT) {
        var amazonResponse = httpResponse.getXmlPayload();
        if (amazonResponse is xml) {
            return setResponseError(amazonResponse["Message"].getTextValue());
        } else {
            return setResponseError(XML_EXTRACTION_ERROR_MSG);
        }
    }
}

function extractResponsePayload(http:Response response) returns @tainted byte[]| error {
    var binaryObjectContent = response.getBinaryPayload();
    if (binaryObjectContent is byte[]) {
        return binaryObjectContent;
    } else {
        error err = error(message = "Invalid response payload", code = AMAZONS3_ERROR_CODE);
        return err;
    }
}

function equalsIgnoreCase(string str1, string str2) returns boolean {
    if (str1.toUpperAscii() == str2.toUpperAscii()) {
        return true;
    } else {
        return false;
    }
}

function replaceText(string originalText, string textToReplace, string replacement) returns string|error {
    handle originalTextHandle = java:fromString(originalText);
    handle textToReplaceHandle = java:fromString(textToReplace);
    handle replacementHandle = java:fromString(replacement);
    string? modifiedText = java:toString(replace(originalTextHandle, textToReplaceHandle, replacementHandle));
    if (modifiedText is string) {
        return modifiedText;
    } else {
        string errorMessage = "Error occured whle replacing the text";
        error err = error(errorMessage, message = errorMessage);
        return err;
    }
}

function replaceFirstText(string originalText, string textToReplace, string replacement) returns string|error {
    handle originalTextHandle = java:fromString(originalText);
    handle textToReplaceHandle = java:fromString(textToReplace);
    handle replacementHandle = java:fromString(replacement);
    string? modifiedText = java:toString(replaceFirst(originalTextHandle, textToReplaceHandle, replacementHandle));
    if (modifiedText is string) {
        return modifiedText;
    } else {
        string errorMessage = "Error occured whle replacing the first text";
        error err = error(errorMessage, message = errorMessage);
        return err;
    }
}

function getLastIndexOf(string originalText, string str) returns int {
    handle originalTextHandle = java:fromString(originalText);
    handle strHandle = java:fromString(str);
    return lastIndexOf(originalTextHandle, strHandle);
}
