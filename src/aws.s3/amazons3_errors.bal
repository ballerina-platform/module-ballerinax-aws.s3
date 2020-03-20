// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
# + cause - Cause of the error; If this error occurred due to another error (Probably from another module)
public type ErrorDetail record {
    string message;
    error cause?;
};

// Client error reasons
public const CLIENT_CREDENTIALS_VERIFICATION_ERROR = "{ballerinax/aws.s3}ClientCredentialsVerificationError";
public const CLIENT_CONFIG_INITIALIZATION_ERROR = "{ballerinax/aws.s3}ClientConfigInitializationError";
public const SIGNATURE_GENERATION_ERROR = "{ballerinax/aws.s3}SignatureGenerationError";
public const API_INVOCATION_ERROR = "{ballerinax/aws.s3}ApiInvocationError";
public const HTTP_RESPONSE_HANDLING_ERROR = "{ballerinax/aws.s3}HttpResponseHandlingError";

// Module errors
public const STRING_UTIL_ERROR = "{ballerinax/aws.s3}StringUtilError";
public type StringUtilError error<STRING_UTIL_ERROR, ErrorDetail>;

// Client errors
public type CLIENT_ERROR_REASONS CLIENT_CONFIG_INITIALIZATION_ERROR|CLIENT_CREDENTIALS_VERIFICATION_ERROR|
                                 SIGNATURE_GENERATION_ERROR|HTTP_RESPONSE_HANDLING_ERROR|API_INVOCATION_ERROR;

public type ClientError error<CLIENT_ERROR_REASONS, ErrorDetail>;

// Server error Reasons
public const ACCESS_DENIED = "{ballerinax/aws.s3}AccessDenied";
public const ACCOUNT_PROBLEM = "{ballerinax/aws.s3}AccountProblem";
public const ALL_ACCESS_DISABLED = "{ballerinax/aws.s3}AllAccessDisabled";
public const AMBIGUOUS_GRANT_BY_EMAIL_ADDRESS = "{ballerinax/aws.s3}AmbiguousGrantByEmailAddress";
public const AUTHORIZATION_HEADER_MALFORMED = "{ballerinax/aws.s3}AuthorizationHeaderMalformed";
public const BAD_DIGEST = "{ballerinax/aws.s3}BadDigest";
public const BUCKET_ALREADY_EXISTS = "{ballerinax/aws.s3}BucketAlreadyExists";
public const BUCKET_ALREADY_OWNED_BY_YOU = "{ballerinax/aws.s3}BucketAlreadyOwnedByYou";
public const BUCKET_NOT_EMPTY = "{ballerinax/aws.s3}BucketNotEmpty";
public const CREDENTIALS_NOT_SUPPORTED = "{ballerinax/aws.s3}CredentialsNotSupported";
public const CROSS_LOCATION_LOGGING_PROHIBITED = "{ballerinax/aws.s3}CrossLocationLoggingProhibited";
public const ENTITY_TOO_SMALL = "{ballerinax/aws.s3}EntityTooSmall";
public const ENTITY_TOO_LARGE = "{ballerinax/aws.s3}EntityTooLarge";
public const EXPIRED_TOKEN = "{ballerinax/aws.s3}ExpiredToken";
public const ILLEGAL_VERSIONING_CONFIGURATION_EXCEPTION = "{ballerinax/aws.s3}IllegalVersioningConfigurationException";
public const INCOMPLETE_BODY = "{ballerinax/aws.s3}IncompleteBody";
public const INCORRECT_NUMBER_OF_FILES_IN_POST_REQUEST = "{ballerinax/aws.s3}IncorrectNumberOfFilesInPostRequest";
public const INLINE_DATA_TOO_LARGE = "{ballerinax/aws.s3}InlineDataTooLarge";
public const INTERNAL_ERROR = "{ballerinax/aws.s3}InternalError";
public const INVALID_ACCESS_KEY_ID = "{ballerinax/aws.s3}InvalidAccessKeyId";
public const INVALID_ADDRESSING_HEADER = "{ballerinax/aws.s3}InvalidAddressingHeader";
public const INVALID_ARGUMENT = "{ballerinax/aws.s3}InvalidArgument";
public const INVALID_BUCKET_NAME = "{ballerinax/aws.s3}InvalidBucketName";
public const INVALID_BUCKET_STATE = "{ballerinax/aws.s3}InvalidBucketState";
public const INVALID_DIGEST = "{ballerinax/aws.s3}InvalidDigest";
public const INVALID_ENCRYPTION_ALGORITHM_ERROR = "{ballerinax/aws.s3}InvalidEncryptionAlgorithmError";
public const INVALID_LOCATION_CONSTRAINT = "{ballerinax/aws.s3}InvalidLocationConstraint";
public const INVALID_OBJECT_STATE = "{ballerinax/aws.s3}InvalidObjectState";
public const INVALID_PART = "{ballerinax/aws.s3}InvalidPart";
public const INVALID_PART_ORDER = "{ballerinax/aws.s3}InvalidPartOrder";
public const INVALID_PAYER = "{ballerinax/aws.s3}InvalidPayer";
public const INVALID_POLICY_DOCUMENT = "{ballerinax/aws.s3}InvalidPolicyDocument";
public const INVALID_RANGE = "{ballerinax/aws.s3}InvalidRange";
public const INVALID_REQUEST = "{ballerinax/aws.s3}InvalidRequest";
public const INVALID_SECURITY = "{ballerinax/aws.s3}InvalidSecurity";
public const INVALID_SOAP_REQUEST = "{ballerinax/aws.s3}InvalidSOAPRequest";
public const INVALID_STORAGE_CLASS = "{ballerinax/aws.s3}InvalidStorageClass";
public const INVALID_TARGET_BUCKET_FOR_LOGGING = "{ballerinax/aws.s3}InvalidTargetBucketForLogging";
public const INVALID_TOKEN = "{ballerinax/aws.s3}InvalidToken";
public const INVALID_URI = "{ballerinax/aws.s3}InvalidURI";
public const KEY_TOO_LONG_ERROR = "{ballerinax/aws.s3}KeyTooLongError";
public const MALFORMED_ACL_ERROR = "{ballerinax/aws.s3}MalformedACLError";
public const MALFORMED_POST_REQUEST = "{ballerinax/aws.s3}MalformedPOSTRequest";
public const MALFORMED_XML = "{ballerinax/aws.s3}MalformedXML";
public const MAX_MESSAGE_LENGTH_EXCEEDED = "{ballerinax/aws.s3}MaxMessageLengthExceeded";
public const MAX_POST_PRE_DATA_LENGTH_EXCEEDED_ERROR = "{ballerinax/aws.s3}MaxPostPreDataLengthExceededError";
public const METADATA_TOO_LARGE = "{ballerinax/aws.s3}MetadataTooLarge";
public const METHOD_NOT_ALLOWED = "{ballerinax/aws.s3}MethodNotAllowed";
public const MISSING_ATTACHMENT = "{ballerinax/aws.s3}MissingAttachment";
public const MISSING_CONTENT_LENGTH = "{ballerinax/aws.s3}MissingContentLength";
public const MISSING_REQUEST_BODY_ERROR = "{ballerinax/aws.s3}MissingRequestBodyError";
public const MISSING_SECURITY_ELEMENT = "{ballerinax/aws.s3}MissingSecurityElement";
public const MISSING_SECURITY_HEADER = "{ballerinax/aws.s3}MissingSecurityHeader";
public const NO_LOGGING_STATUS_FOR_KEY = "{ballerinax/aws.s3}NoLoggingStatusForKey";
public const NO_SUCH_BUCKET = "{ballerinax/aws.s3}NoSuchBucket";
public const NO_SUCH_BUCKET_POLICY = "{ballerinax/aws.s3}NoSuchBucketPolicy";
public const NO_SUCH_KEY = "{ballerinax/aws.s3}NoSuchKey";
public const NO_SUCH_LIFECYCLE_CONFIGURATION = "{ballerinax/aws.s3}NoSuchLifecycleConfiguration";
public const NO_SUCH_UPLOAD = "{ballerinax/aws.s3}NoSuchUpload";
public const NO_SUCH_VERSION = "{ballerinax/aws.s3}NoSuchVersion";
public const NOT_IMPLEMENTED = "{ballerinax/aws.s3}NotImplemented";
public const NOT_SIGNED_UP = "{ballerinax/aws.s3}NotSignedUp";
public const OPERATION_ABORTED = "{ballerinax/aws.s3}OperationAborted";
public const PERMANENT_REDIRECT = "{ballerinax/aws.s3}PermanentRedirect";
public const PRECONDITION_FAILED = "{ballerinax/aws.s3}PreconditionFailed";
public const REDIRECT = "{ballerinax/aws.s3}Redirect";
public const RESTORE_ALREADY_IN_PROGRESS = "{ballerinax/aws.s3}RestoreAlreadyInProgress";
public const REQUEST_IS_NOT_MULTI_PART_CONTENT = "{ballerinax/aws.s3}RequestIsNotMultiPartContent";
public const REQUEST_TIMEOUT = "{ballerinax/aws.s3}RequestTimeout";
public const REQUEST_TIME_TOO_SKEWED = "{ballerinax/aws.s3}RequestTimeTooSkewed";
public const REQUEST_TORRENT_OF_BUCKET_ERROR = "{ballerinax/aws.s3}RequestTorrentOfBucketError";
public const SERVER_SIDE_ENCRYPTION_CONFIGURATION_NOT_FOUND_ERROR = "{ballerinax/aws.s3}ServerSideEncryptionConfigurationNotFoundError";
public const SERVICE_UNAVAILABLE = "{ballerinax/aws.s3}ServiceUnavailable";
public const SIGNATURE_DOES_NOT_MATCH = "{ballerinax/aws.s3}SignatureDoesNotMatch";
public const SLOW_DOWN = "{ballerinax/aws.s3}SlowDown";
public const TEMPORARY_REDIRECT = "{ballerinax/aws.s3}TemporaryRedirect";
public const TOKEN_REFRESH_REQUIRED = "{ballerinax/aws.s3}TokenRefreshRequired";
public const TOO_MANY_BUCKETS = "{ballerinax/aws.s3}TooManyBuckets";
public const UNEXPECTED_CONTENT = "{ballerinax/aws.s3}UnexpectedContent";
public const UNRESOLVABLE_GRANT_BY_EMAIL_ADDRESS = "{ballerinax/aws.s3}UnresolvableGrantByEmailAddress";
public const USER_KEY_MUST_BE_SPECIFIED = "{ballerinax/aws.s3}UserKeyMustBeSpecified";

public type BUCKET_OPERATION_ERROR_REASONS ACCESS_DENIED|ACCOUNT_PROBLEM|ALL_ACCESS_DISABLED|
        AMBIGUOUS_GRANT_BY_EMAIL_ADDRESS|AUTHORIZATION_HEADER_MALFORMED|BAD_DIGEST|BUCKET_ALREADY_EXISTS|
        BUCKET_ALREADY_OWNED_BY_YOU|BUCKET_NOT_EMPTY|CREDENTIALS_NOT_SUPPORTED|CROSS_LOCATION_LOGGING_PROHIBITED|
        ENTITY_TOO_SMALL|ENTITY_TOO_LARGE|EXPIRED_TOKEN|ILLEGAL_VERSIONING_CONFIGURATION_EXCEPTION|INCOMPLETE_BODY|
        INCORRECT_NUMBER_OF_FILES_IN_POST_REQUEST|INLINE_DATA_TOO_LARGE|INTERNAL_ERROR|INVALID_ACCESS_KEY_ID|
        INVALID_ADDRESSING_HEADER|INVALID_ARGUMENT|INVALID_BUCKET_NAME|INVALID_BUCKET_STATE|INVALID_DIGEST|
        INVALID_ENCRYPTION_ALGORITHM_ERROR|INVALID_LOCATION_CONSTRAINT|INVALID_OBJECT_STATE|INVALID_PART|
        INVALID_PART_ORDER|INVALID_PAYER|INVALID_POLICY_DOCUMENT|INVALID_RANGE|INVALID_REQUEST|INVALID_SECURITY|
        INVALID_SOAP_REQUEST|INVALID_STORAGE_CLASS|INVALID_TARGET_BUCKET_FOR_LOGGING|INVALID_TOKEN|INVALID_URI|
        KEY_TOO_LONG_ERROR|MALFORMED_ACL_ERROR|MALFORMED_POST_REQUEST|MALFORMED_XML|MAX_MESSAGE_LENGTH_EXCEEDED|
        MAX_POST_PRE_DATA_LENGTH_EXCEEDED_ERROR|METADATA_TOO_LARGE|METHOD_NOT_ALLOWED|MISSING_ATTACHMENT|
        MISSING_CONTENT_LENGTH|MISSING_REQUEST_BODY_ERROR|MISSING_SECURITY_ELEMENT|MISSING_SECURITY_HEADER|
        NO_LOGGING_STATUS_FOR_KEY|NO_SUCH_BUCKET|NO_SUCH_BUCKET_POLICY|NO_SUCH_KEY|NO_SUCH_LIFECYCLE_CONFIGURATION|
        NO_SUCH_UPLOAD|NO_SUCH_VERSION|NOT_IMPLEMENTED|NOT_SIGNED_UP|OPERATION_ABORTED|PERMANENT_REDIRECT|
        PRECONDITION_FAILED|REDIRECT|RESTORE_ALREADY_IN_PROGRESS|REQUEST_IS_NOT_MULTI_PART_CONTENT|REQUEST_TIMEOUT|
        REQUEST_TIME_TOO_SKEWED|REQUEST_TORRENT_OF_BUCKET_ERROR|SERVER_SIDE_ENCRYPTION_CONFIGURATION_NOT_FOUND_ERROR|
        SERVICE_UNAVAILABLE|SIGNATURE_DOES_NOT_MATCH|SLOW_DOWN|TEMPORARY_REDIRECT|TOKEN_REFRESH_REQUIRED|
        TOO_MANY_BUCKETS|UNEXPECTED_CONTENT|UNRESOLVABLE_GRANT_BY_EMAIL_ADDRESS|USER_KEY_MUST_BE_SPECIFIED;

public type BucketOperationError error<BUCKET_OPERATION_ERROR_REASONS, ErrorDetail>;

public const UNKNOWN_SERVER_ERROR = "{ballerinax/aws.s3}UnknownServerError";
public type UnknownServerError error<UNKNOWN_SERVER_ERROR, ErrorDetail>;

# Ballerina AmazonS3 Union Errors
public type ConnectorError ServerError|ClientError|StringUtilError;

public type ServerError BucketOperationError|UnknownServerError;

// Error messages.
const string UNKNOWN_SERVER_ERROR_MSG = "Unknown Amazon S3 server error occured.";
const string EMPTY_VALUES_FOR_CREDENTIALS_ERROR_MSG = "Empty values set for accessKeyId or secretAccessKey credential";
const string CLIENT_CREDENTIALS_VERIFICATION_ERROR_MSG = "Error occured while verifying client credentials.";
const string DATE_STRING_GENERATION_ERROR_MSG = "Error occured while generating date strings.";
const string CANONICAL_URI_GENERATION_ERROR_MSG = "Error occured hwile generating canonical URI.";
const string CANONICAL_QUERY_STRING_GENERATION_ERROR_MSG = "Error occured while generating canonical query string.";
const string STRING_MANUPULATION_ERROR_MSG = "Error occured during string manipulation.";
const string XML_EXTRACTION_ERROR_MSG = "Error occurred while accessing the XML payload from the http response.";
const string API_INVOCATION_ERROR_MSG = "Error occurred while invoking the AmazonS3 API while ";
const string BINARY_CONTENT_EXTRACTION_ERROR_MSG = "Error occured while accessing binary content from the http response";
