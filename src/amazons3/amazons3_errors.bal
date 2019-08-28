// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# Holds the details of an AmazonS3 error
#
# + message - Specific error message for the error
# + errorCode - Error code for the error
# + cause - Cause of the error; If this error occurred due to another error (Probably from another module)
public type ErrorDetail record {
    string message;
    string errorCode;
    error cause?;
};

// Ballerina AmazonS3 Client Error Types

public const CLIENT_CONFIG_INITIALIZATION_FAILED = "{wso2/amazons3}ClientConfigInitializationFailed";
public type ClientConfigInitializationFailed error<CLIENT_CONFIG_INITIALIZATION_FAILED, ErrorDetail>;

public const STRING_UTIL_ERROR = "{wso2/amazons3}StringUtilError";
public type StringUtilError error<STRING_UTIL_ERROR, ErrorDetail>;

public const SIGNATURE_GENERATION_ERROR = "{wso2/amazons3}SignatureGenerationError";
public type SignatureGenerationError error<SIGNATURE_GENERATION_ERROR, ErrorDetail>;

public const BUCKET_CREATION_FAILED = "{wso2/amazons3}BucketCreationFailed";
public type BucketCreationFailed error<BUCKET_CREATION_FAILED, ErrorDetail>;

public const OBJECT_CREATION_FAILED = "{wso2/amazons3}ObjectCreationFailed";
public type ObjectCreationFailed error<OBJECT_CREATION_FAILED, ErrorDetail>;

public const OBJECT_RETRIEVING_FAILED = "{wso2/amazons3}ObjectRetrievingFailed";
public type ObjectRetrievingFailed error<OBJECT_RETRIEVING_FAILED, ErrorDetail>;

public const BUCKET_LISTING_FAILED = "{wso2/amazons3}BucketListingFailed";
public type BucketListingFailed error<BUCKET_LISTING_FAILED, ErrorDetail>;

public const OBJECT_LISTING_FAILED = "{wso2/amazons3}ObjectListingFailed";
public type ObjectListingFailed error<OBJECT_LISTING_FAILED, ErrorDetail>;

public const OBJECT_DELETION_FAILED = "{wso2/amazons3}ObjectDeletionFailed";
public type ObjectDeletionFailed error<OBJECT_DELETION_FAILED, ErrorDetail>;

public const BUCKET_DELETION_FAILED = "{wso2/amazons3}BucketDeletionFailed";
public type BucketDeletionFailed error<BUCKET_DELETION_FAILED, ErrorDetail>;

public const HTTP_RESPONSE_HANDLING_FAILED = "{wso2/amazons3}HttpResponseHandlingFailed";
public type HttpResponseHandlingFailed error<HTTP_RESPONSE_HANDLING_FAILED, ErrorDetail>;

public const SERVER_ERROR = "{wso2/amazons3}ServerError";
public type ServerError error<SERVER_ERROR, ErrorDetail>;

# Ballerina AmazonS3 Union Errors
public type ConnectorError ServerError|ClientError;

public type ClientError StringUtilError|ClientConfigInitializationFailed|SignatureGenerationError|
                        BucketCreationFailed|HttpResponseHandlingFailed|BucketListingFailed|HttpResponseHandlingFailed|
                        ObjectListingFailed|ObjectCreationFailed|ObjectRetrievingFailed|ObjectDeletionFailed|
                        BucketDeletionFailed;

// Error messages.
const string CLIENT_CONFIG_INIT_FAILED_MSG = "Error occured while initializing client configurations.";
const string SIGNATURE_GENEREATION_ERROR_MSG = "Error occurred while generating the Amazon signature header.";
const string AMAZON_S3_SERVER_ERROR_MSG = "Amazons S3 server error occured.";
const string BUCKET_CREATION_FAILED_MSG = "Error occured while creating s3 bucket.";
const string OBJECT_CREATION_FAILED_MSG = "Error occured while creating object.";
const string BUCKET_LISTING_FAILED_MSG = "Error occured while listing buckets details.";
const string OBJECT_LISTING_FAILED_MSG = "Error occured while listing objects from bucket.";
const string OBJECT_RETRIEVING_FAILED_MSG = "Error occured while retrieving object from s3 bucket";
const string OBJECT_DELETION_FAILED_MSG = "Error occured while deleting object from s3 bucket";
const string BUCKET_DELETION_FAILED_MSG = "Error occured while deleting bucket";
const string XML_EXTRACTION_ERROR_MSG = "Error occurred while accessing the XML payload of the response.";
const string API_INVOCATION_ERROR_MSG = "Error occurred while invoking the AmazonS3 API.";
