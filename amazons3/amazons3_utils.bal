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

import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/io;
import ballerina/system;
import ballerina/time;

function generateSignature(http:Request request, string accessKeyId, string secretAccessKey, string region,
                           string httpVerb, string requestURI, string payload) {

    string canonicalRequest = "";
    string canonicalQueryString = "";
    string stringToSign = "";
    string payloadBuilder = "";
    string authHeader = "";
    string amzDate = "";
    string shortDate = "";
    string signedHeader = "";
    string canonicalHeaders = "";
    string signedHeaders = "";
    string requestPayload = "";
    string encodedrequestURIValue = "";
    string signValue = "";

    time:Time time = time:toTimeZone(time:currentTime(), "GMT");
    amzDate = time:format(time, ISO8601_BASIC_DATE_FORMAT);
    shortDate = time:format(time, SHORT_DATE_FORMAT);

    request.setHeader(X_AMZ_DATE, amzDate);
    canonicalRequest = httpVerb;
    canonicalRequest = canonicalRequest + "\n";
    var value = http:encode(requestURI, UTF_8);
    if (value is string) {
        encodedrequestURIValue = value;
    } else {
        error err = error(AMAZONS3_ERROR_CODE, { message: "Error occurred when converting to string"});
        panic err;
    }
    canonicalRequest = canonicalRequest + encodedrequestURIValue.replace("%2F", "/");
    canonicalRequest = canonicalRequest + "\n";
    canonicalQueryString = "";
    canonicalRequest = canonicalRequest + canonicalQueryString;
    canonicalRequest = canonicalRequest + "\n";

    if (payload != "" && payload != UNSIGNED_PAYLOAD){
        canonicalHeaders = canonicalHeaders + CONTENT_TYPE.toLower();
        canonicalHeaders = canonicalHeaders + ":";
        canonicalHeaders = canonicalHeaders + request.getHeader(CONTENT_TYPE.toLower());
        canonicalHeaders = canonicalHeaders + "\n";
        signedHeader = signedHeader + CONTENT_TYPE.toLower();
        signedHeader = signedHeader + ";";
    }

    canonicalHeaders = canonicalHeaders + HOST.toLower();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(HOST.toLower());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + HOST.toLower();
    signedHeader = signedHeader + ";";

    if (payload == UNSIGNED_PAYLOAD){
        canonicalHeaders = canonicalHeaders + X_AMZ_CONTENT_SHA256.toLower();
        canonicalHeaders = canonicalHeaders + ":";
        canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_CONTENT_SHA256.toLower());
        canonicalHeaders = canonicalHeaders + "\n";
        signedHeader = signedHeader + X_AMZ_CONTENT_SHA256.toLower();
        signedHeader = signedHeader + ";";
    }

    canonicalHeaders = canonicalHeaders + X_AMZ_DATE.toLower();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_DATE.toLower());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + X_AMZ_DATE.toLower();
    signedHeader = signedHeader;

    canonicalRequest = canonicalRequest + canonicalHeaders;
    canonicalRequest = canonicalRequest + "\n";
    signedHeaders = "";
    signedHeaders = signedHeader;
    canonicalRequest = canonicalRequest + signedHeaders;
    canonicalRequest = canonicalRequest + "\n";
    payloadBuilder = payload;
    requestPayload = "";
    requestPayload = payloadBuilder;

    if (payloadBuilder == UNSIGNED_PAYLOAD) {
        requestPayload = payloadBuilder;
    } else {
        requestPayload = encoding:encodeHex(crypto:hashSha256(payloadBuilder.toByteArray(UTF_8))).toLower();
    }

    canonicalRequest = canonicalRequest + requestPayload;
    //Start creating the string to sign
    stringToSign = stringToSign + AWS4_HMAC_SHA256;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + amzDate;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + shortDate;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + region;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + SERVICE_NAME;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + TERMINATION_STRING;
    stringToSign = stringToSign + "\n";

    stringToSign = stringToSign + encoding:encodeHex(crypto:hashSha256(canonicalRequest.toByteArray(UTF_8))).toLower();

    signValue = (AWS4 + secretAccessKey);

    byte[] dateKey = crypto:hmacSha256(shortDate.toByteArray(UTF_8), signValue.toByteArray(UTF_8));
    byte[] regionKey = crypto:hmacSha256(region.toByteArray(UTF_8), dateKey);
    byte[] serviceKey = crypto:hmacSha256(SERVICE_NAME.toByteArray(UTF_8), regionKey);
    byte[] signingKey = crypto:hmacSha256(TERMINATION_STRING.toByteArray(UTF_8), serviceKey);

    authHeader = authHeader + (AWS4_HMAC_SHA256);
    authHeader = authHeader + (" ");
    authHeader = authHeader + (CREDENTIAL);
    authHeader = authHeader + ("=");
    authHeader = authHeader + (accessKeyId);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (shortDate);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (region);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (SERVICE_NAME);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (TERMINATION_STRING);
    authHeader = authHeader + (",");
    authHeader = authHeader + (SIGNED_HEADER);
    authHeader = authHeader + ("=");
    authHeader = authHeader + (signedHeaders);
    authHeader = authHeader + (",");
    authHeader = authHeader + (SIGNATURE);
    authHeader = authHeader + ("=");

    string encodedStr = encoding:encodeHex(crypto:hmacSha256(stringToSign.toByteArray(UTF_8), signingKey));
    authHeader = authHeader + encodedStr.toLower();

    request.setHeader(AUTHORIZATION, authHeader);
}

function setResponseError(int statusCode, xml xmlResponse) returns error {
    error err = error(AMAZONS3_ERROR_CODE, {message : xmlResponse["Message"].getTextValue() });
    return err;
}
