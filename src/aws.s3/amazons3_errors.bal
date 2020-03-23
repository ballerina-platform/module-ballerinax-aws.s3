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

# Identifies client credentials verification error.
public const CLIENT_CREDENTIALS_VERIFICATION_ERROR = "{ballerinax/aws.s3}ClientCredentialsVerificationError";
# Represents client credentials verification error.
public type ClientCredentialsVerificationError error<CLIENT_CREDENTIALS_VERIFICATION_ERROR, ErrorDetail>;

# Identifies client config initialization error.
public const CLIENT_CONFIG_INITIALIZATION_ERROR = "{ballerinax/aws.s3}ClientConfigInitializationError";
# Represents client config initialization error.
public type ClientConfigInitializationError error<CLIENT_CONFIG_INITIALIZATION_ERROR, ErrorDetail>;

# Identifies signature generation error.
public const SIGNATURE_GENERATION_ERROR = "{ballerinax/aws.s3}SignatureGenerationError";
# Represents signature generation error.
public type SignatureGenerationError error<SIGNATURE_GENERATION_ERROR, ErrorDetail>;

# Identifies API invokation error.
public const API_INVOCATION_ERROR = "{ballerinax/aws.s3}ApiInvocationError";
# Represents API invokation error.
public type ApiInvocationError error<API_INVOCATION_ERROR, ErrorDetail>;

# Identifies http response handling error.
public const HTTP_RESPONSE_HANDLING_ERROR = "{ballerinax/aws.s3}HttpResponseHandlingError";
# Represents http response handling error.
public type HttpResponseHandlingError error<HTTP_RESPONSE_HANDLING_ERROR, ErrorDetail>;

# Identifies string util error.
public const STRING_UTIL_ERROR = "{ballerinax/aws.s3}StringUtilError";
# Represents string util error.
public type StringUtilError error<STRING_UTIL_ERROR, ErrorDetail>;

# Identifies access deny.
public const ACCESS_DENIED = "{ballerinax/aws.s3}AccessDenied";
# Represents access denied error.
public type AccessDeniedError error<ACCESS_DENIED, ErrorDetail>;

# Identifies account problem.
public const ACCOUNT_PROBLEM = "{ballerinax/aws.s3}AccountProblem";
# Represents access denied error.
public type AccountProblemError error<ACCOUNT_PROBLEM, ErrorDetail>;

# Identifies all access disable.
public const ALL_ACCESS_DISABLED = "{ballerinax/aws.s3}AllAccessDisabled";
# Represents all access disable error.
public type AllAccessDisabledError error<ALL_ACCESS_DISABLED, ErrorDetail>;

# Identifies ambiguous grant by email address.
public const AMBIGUOUS_GRANT_BY_EMAIL_ADDRESS = "{ballerinax/aws.s3}AmbiguousGrantByEmailAddress";
# Represents ambiguous grant by email address error.
public type AmbiguousGrantByEmailAddressError error<AMBIGUOUS_GRANT_BY_EMAIL_ADDRESS, ErrorDetail>;

# Identifies authorization header malforms.
public const AUTHORIZATION_HEADER_MALFORMED = "{ballerinax/aws.s3}AuthorizationHeaderMalformed";
# Represents authorization header malformed error.
public type AuthorizationHeaderMalformedError error<AUTHORIZATION_HEADER_MALFORMED, ErrorDetail>;

# Identifies bad digest.
public const BAD_DIGEST = "{ballerinax/aws.s3}BadDigest";
# Represents bad digest error.
public type BadDigestError error<BAD_DIGEST, ErrorDetail>;

# Identifies bucket already exists.
public const BUCKET_ALREADY_EXISTS = "{ballerinax/aws.s3}BucketAlreadyExists";
# Represents bucket already exists error.
public type BucketAlreadyExistsError error<BUCKET_ALREADY_EXISTS, ErrorDetail>;

# Identifies bucket already owned by you.
public const BUCKET_ALREADY_OWNED_BY_YOU = "{ballerinax/aws.s3}BucketAlreadyOwnedByYou";
# Represents bucket already owned by you error.
public type BucketAlreadyOwnedByYouError error<BUCKET_ALREADY_OWNED_BY_YOU, ErrorDetail>;

# Identifies bucket not empty.
public const BUCKET_NOT_EMPTY = "{ballerinax/aws.s3}BucketNotEmpty";
# Represents bucket not empty error.
public type BucketNotEmptyError error<BUCKET_NOT_EMPTY, ErrorDetail>;

# Identifies credentials not supported.
public const CREDENTIALS_NOT_SUPPORTED = "{ballerinax/aws.s3}CredentialsNotSupported";
# Represents credentials not supported error.
public type CredentialsNotSupportedError error<CREDENTIALS_NOT_SUPPORTED, ErrorDetail>;

# Identifies cross location logging prohibited.
public const CROSS_LOCATION_LOGGING_PROHIBITED = "{ballerinax/aws.s3}CrossLocationLoggingProhibited";
# Represents cross location logging prohibited error.
public type CrossLocationLoggingProhibitedError error<CROSS_LOCATION_LOGGING_PROHIBITED, ErrorDetail>;

# Identifies entry too small.
public const ENTITY_TOO_SMALL = "{ballerinax/aws.s3}EntityTooSmall";
# Represents entry too small error.
public type EntityTooSmallError error<ENTITY_TOO_SMALL, ErrorDetail>;

# Identifies entry too large.
public const ENTITY_TOO_LARGE = "{ballerinax/aws.s3}EntityTooLarge";
# Represents entry too large error.
public type EntityTooLargeError error<ENTITY_TOO_LARGE, ErrorDetail>;

# Identifies expired token.
public const EXPIRED_TOKEN = "{ballerinax/aws.s3}ExpiredToken";
# Represents expired token error.
public type ExpiredTokenError error<EXPIRED_TOKEN, ErrorDetail>;

# Identifies illegal versioning configuration exception.
public const ILLEGAL_VERSIONING_CONFIGURATION_EXCEPTION = "{ballerinax/aws.s3}IllegalVersioningConfigurationException";
# Represents illegal versioning configuration exception error.
public type IllegalVersioningConfigurationExceptionError error<ILLEGAL_VERSIONING_CONFIGURATION_EXCEPTION, ErrorDetail>;

# Identifies incomplete body.
public const INCOMPLETE_BODY = "{ballerinax/aws.s3}IncompleteBody";
# Represents incomplete body error.
public type IncompleteBodyError error<INCOMPLETE_BODY, ErrorDetail>;

# Identifies incorrect number of files in POST request.
public const INCORRECT_NUMBER_OF_FILES_IN_POST_REQUEST = "{ballerinax/aws.s3}IncorrectNumberOfFilesInPostRequest";
# Represents incorrect number of files in POST request error.
public type IncorrectNumberOfFilesInPostRequestError error<INCORRECT_NUMBER_OF_FILES_IN_POST_REQUEST, ErrorDetail>;

# Identifies inline data too large.
public const INLINE_DATA_TOO_LARGE = "{ballerinax/aws.s3}InlineDataTooLarge";
# Represents inline data too large error.
public type InlineDataTooLargeError error<INLINE_DATA_TOO_LARGE, ErrorDetail>;

# Identifies internal error.
public const INTERNAL_ERROR = "{ballerinax/aws.s3}InternalError";
# Represents internal error.
public type InternalError error<INTERNAL_ERROR, ErrorDetail>;

# Identifies invalid access key id.
public const INVALID_ACCESS_KEY_ID = "{ballerinax/aws.s3}InvalidAccessKeyId";
# Represents invalid access key id error.
public type InvalidAccessKeyIdError error<INVALID_ACCESS_KEY_ID, ErrorDetail>;

# Identifies invalid address header.
public const INVALID_ADDRESSING_HEADER = "{ballerinax/aws.s3}InvalidAddressingHeader";
# Represents invalid address header error.
public type InvalidAddressingHeaderError error<INVALID_ADDRESSING_HEADER, ErrorDetail>;

# Identifies invalid argument.
public const INVALID_ARGUMENT = "{ballerinax/aws.s3}InvalidArgument";
# Represents invalid argument error.
public type InvalidArgumentError error<INVALID_ARGUMENT, ErrorDetail>;

# Identifies invalid bucket name.
public const INVALID_BUCKET_NAME = "{ballerinax/aws.s3}InvalidBucketName";
# Represents invalid bucket name error.
public type InvalidBucketNameError error<INVALID_BUCKET_NAME, ErrorDetail>;

# Identifies invalid bucket state.
public const INVALID_BUCKET_STATE = "{ballerinax/aws.s3}InvalidBucketState";
# Represents invalid bucket state error.
public type InvalidBucketStateError error<INVALID_BUCKET_STATE, ErrorDetail>;

# Identifies invalid digest.
public const INVALID_DIGEST = "{ballerinax/aws.s3}InvalidDigest";
# Represents invalid digest error.
public type InvalidDigestError error<INVALID_DIGEST, ErrorDetail>;

# Identifies invalid encryption algorithm error.
public const INVALID_ENCRYPTION_ALGORITHM_ERROR = "{ballerinax/aws.s3}InvalidEncryptionAlgorithmError";
# Represents invalid encryption algorithm error.
public type InvalidEncryptionAlgorithmError error<INVALID_ENCRYPTION_ALGORITHM_ERROR, ErrorDetail>;

# Identifies invalid location constraint.
public const INVALID_LOCATION_CONSTRAINT = "{ballerinax/aws.s3}InvalidLocationConstraint";
# Represents invalid location constraint error.
public type InvalidLocationConstraintError error<INVALID_LOCATION_CONSTRAINT, ErrorDetail>;

# Identifies invalid object state.
public const INVALID_OBJECT_STATE = "{ballerinax/aws.s3}InvalidObjectState";
# Represents invalid object state error.
public type InvalidObjectStateError error<INVALID_OBJECT_STATE, ErrorDetail>;

# Identifies invalid part.
public const INVALID_PART = "{ballerinax/aws.s3}InvalidPart";
# Represents invalid part error.
public type InvalidPartError error<INVALID_PART, ErrorDetail>;

# Identifies invalid part order.
public const INVALID_PART_ORDER = "{ballerinax/aws.s3}InvalidPartOrder";
# Represents invalid part order error.
public type InvalidPartOrderError error<INVALID_PART_ORDER, ErrorDetail>;

# Identifies invalid payer.
public const INVALID_PAYER = "{ballerinax/aws.s3}InvalidPayer";
# Represents invalid payer error.
public type InvalidPayerError error<INVALID_PAYER, ErrorDetail>;

# Identifies invalid policy document.
public const INVALID_POLICY_DOCUMENT = "{ballerinax/aws.s3}InvalidPolicyDocument";
# Represents invalid policy document error.
public type InvalidPolicyDocumentError error<INVALID_POLICY_DOCUMENT, ErrorDetail>;

# Identifies invalid range.
public const INVALID_RANGE = "{ballerinax/aws.s3}InvalidRange";
# Represents invalid range error.
public type InvalidRangeError error<INVALID_RANGE, ErrorDetail>;

# Identifies invalid request.
public const INVALID_REQUEST = "{ballerinax/aws.s3}InvalidRequest";
# Represents invalid request error.
public type InvalidRequestError error<INVALID_REQUEST, ErrorDetail>;

# Identifies invalid security.
public const INVALID_SECURITY = "{ballerinax/aws.s3}InvalidSecurity";
# Represents invalid security error.
public type InvalidSecurityError error<INVALID_SECURITY, ErrorDetail>;

# Identifies invalid SOAP request.
public const INVALID_SOAP_REQUEST = "{ballerinax/aws.s3}InvalidSOAPRequest";
# Represents invalid SOAP request error.
public type InvalidSOAPRequestError error<INVALID_SOAP_REQUEST, ErrorDetail>;

# Identifies invalid storage class.
public const INVALID_STORAGE_CLASS = "{ballerinax/aws.s3}InvalidStorageClass";
# Represents invalid storage class error.
public type InvalidStorageClassError error<INVALID_STORAGE_CLASS, ErrorDetail>;

# Identifies invalid target bucket for logging.
public const INVALID_TARGET_BUCKET_FOR_LOGGING = "{ballerinax/aws.s3}InvalidTargetBucketForLogging";
# Represents invalid target bucket for logging error.
public type InvalidTargetBucketForLoggingError error<INVALID_TARGET_BUCKET_FOR_LOGGING, ErrorDetail>;

# Identifies invalid token.
public const INVALID_TOKEN = "{ballerinax/aws.s3}InvalidToken";
# Represents invalid token error.
public type InvalidTokenError error<INVALID_TOKEN, ErrorDetail>;

# Identifies invalid URI.
public const INVALID_URI = "{ballerinax/aws.s3}InvalidURI";
# Represents invalid URI error.
public type InvalidURIError error<INVALID_URI, ErrorDetail>;

# Identifies key too long error.
public const KEY_TOO_LONG_ERROR = "{ballerinax/aws.s3}KeyTooLongError";
# Represents key too long error.
public type KeyTooLongError error<KEY_TOO_LONG_ERROR, ErrorDetail>;

# Identifies malformed ACL error.
public const MALFORMED_ACL_ERROR = "{ballerinax/aws.s3}MalformedACLError";
# Represents malformed ACL error.
public type MalformedACLError error<MALFORMED_ACL_ERROR, ErrorDetail>;

# Identifies malformed POST request.
public const MALFORMED_POST_REQUEST = "{ballerinax/aws.s3}MalformedPOSTRequest";
# Represents malformed POST request error.
public type MalformedPOSTRequestError error<MALFORMED_POST_REQUEST, ErrorDetail>;

# Identifies malformed XML.
public const MALFORMED_XML = "{ballerinax/aws.s3}MalformedXML";
# Represents malformed XML error.
public type MalformedXMLError error<MALFORMED_XML, ErrorDetail>;

# Identifies max message length exceeded.
public const MAX_MESSAGE_LENGTH_EXCEEDED = "{ballerinax/aws.s3}MaxMessageLengthExceeded";
# Represents max message length exceeded error.
public type MaxMessageLengthExceededError error<MAX_MESSAGE_LENGTH_EXCEEDED, ErrorDetail>;

# Identifies max post pre data length exceeded error.
public const MAX_POST_PRE_DATA_LENGTH_EXCEEDED_ERROR = "{ballerinax/aws.s3}MaxPostPreDataLengthExceededError";
# Represents max post pre data length exceeded error.
public type MaxPostPreDataLengthExceededError error<MAX_POST_PRE_DATA_LENGTH_EXCEEDED_ERROR, ErrorDetail>;

# Identifies meta data too large.
public const METADATA_TOO_LARGE = "{ballerinax/aws.s3}MetadataTooLarge";
# Represents meta data too large error.
public type MetadataTooLargeError error<METADATA_TOO_LARGE, ErrorDetail>;

# Identifies method not allowed.
public const METHOD_NOT_ALLOWED = "{ballerinax/aws.s3}MethodNotAllowed";
# Represents method not allowed error.
public type MethodNotAllowedError error<METHOD_NOT_ALLOWED, ErrorDetail>;

# Identifies missing attachments.
public const MISSING_ATTACHMENT = "{ballerinax/aws.s3}MissingAttachment";
# Represents missing attachments error.
public type MissingAttachmentError error<MISSING_ATTACHMENT, ErrorDetail>;

# Identifies missing content length.
public const MISSING_CONTENT_LENGTH = "{ballerinax/aws.s3}MissingContentLength";
# Represents missing content length error.
public type MissingContentLengthError error<MISSING_CONTENT_LENGTH, ErrorDetail>;

# Identifies missing request body error.
public const MISSING_REQUEST_BODY_ERROR = "{ballerinax/aws.s3}MissingRequestBodyError";
# Represents missing request body error.
public type MissingRequestBodyError error<MISSING_REQUEST_BODY_ERROR, ErrorDetail>;

# Identifies missing security element.
public const MISSING_SECURITY_ELEMENT = "{ballerinax/aws.s3}MissingSecurityElement";
# Represents missing security element error.
public type MissingSecurityElementError error<MISSING_SECURITY_ELEMENT, ErrorDetail>;

# Identifies missing security header.
public const MISSING_SECURITY_HEADER = "{ballerinax/aws.s3}MissingSecurityHeader";
# Represents missing security header error.
public type MissingSecurityHeaderError error<MISSING_SECURITY_HEADER, ErrorDetail>;

# Identifies no logging status for key.
public const NO_LOGGING_STATUS_FOR_KEY = "{ballerinax/aws.s3}NoLoggingStatusForKey";
# Represents no logging status for key error.
public type NoLoggingStatusForKeyError error<NO_LOGGING_STATUS_FOR_KEY, ErrorDetail>;

# Identifies no such bucket.
public const NO_SUCH_BUCKET = "{ballerinax/aws.s3}NoSuchBucket";
# Represents no such bucket error.
public type NoSuchBucketError error<NO_SUCH_BUCKET, ErrorDetail>;

# Identifies no such bucket policy.
public const NO_SUCH_BUCKET_POLICY = "{ballerinax/aws.s3}NoSuchBucketPolicy";
# Represents no such bucket policy error.
public type NoSuchBucketPolicyError error<NO_SUCH_BUCKET_POLICY, ErrorDetail>;

# Identifies no such key.
public const NO_SUCH_KEY = "{ballerinax/aws.s3}NoSuchKey";
# Represents no such key error.
public type NoSuchKeyError error<NO_SUCH_KEY, ErrorDetail>;

# Identifies no such key life cycle configuration.
public const NO_SUCH_LIFECYCLE_CONFIGURATION = "{ballerinax/aws.s3}NoSuchLifecycleConfiguration";
# Represents no such key life cycle configuration error.
public type NoSuchLifecycleConfigurationError error<NO_SUCH_LIFECYCLE_CONFIGURATION, ErrorDetail>;

# Identifies no such upload.
public const NO_SUCH_UPLOAD = "{ballerinax/aws.s3}NoSuchUpload";
# Represents no such upload error.
public type NoSuchUploadError error<NO_SUCH_UPLOAD, ErrorDetail>;

# Identifies no such version.
public const NO_SUCH_VERSION = "{ballerinax/aws.s3}NoSuchVersion";
# Represents no such version error.
public type NoSuchVersionError error<NO_SUCH_VERSION, ErrorDetail>;

# Identifies not implemented.
public const NOT_IMPLEMENTED = "{ballerinax/aws.s3}NotImplemented";
# Represents not implemented error.
public type NotImplementedError error<NOT_IMPLEMENTED, ErrorDetail>;

# Identifies not signed up.
public const NOT_SIGNED_UP = "{ballerinax/aws.s3}NotSignedUp";
# Represents not signed up error.
public type NotSignedUpError error<NOT_SIGNED_UP, ErrorDetail>;

# Identifies operation aborted.
public const OPERATION_ABORTED = "{ballerinax/aws.s3}OPERATION_ABORTED";
# Represents operation aborted error.
public type OperationAbortedError error<OPERATION_ABORTED, ErrorDetail>;

# Identifies permanent redirect.
public const PERMANENT_REDIRECT = "{ballerinax/aws.s3}PermanentRedirect";
# Represents permanent redirect error.
public type PermanentRedirectError error<PERMANENT_REDIRECT, ErrorDetail>;

# Identifies precondition failed.
public const PRECONDITION_FAILED = "{ballerinax/aws.s3}PreconditionFailed";
# Represents precondition failed error.
public type PreconditionFailedError error<PRECONDITION_FAILED, ErrorDetail>;

# Identifies redirect.
public const REDIRECT = "{ballerinax/aws.s3}Redirect";
# Represents redirect error.
public type RedirectError error<REDIRECT, ErrorDetail>;

# Identifies restore already in progress.
public const RESTORE_ALREADY_IN_PROGRESS = "{ballerinax/aws.s3}RestoreAlreadyInProgress";
# Represents restore already in progress error.
public type RestoreAlreadyInProgressError error<RESTORE_ALREADY_IN_PROGRESS, ErrorDetail>;

# Identifies request is not multi part content.
public const REQUEST_IS_NOT_MULTI_PART_CONTENT = "{ballerinax/aws.s3}RequestIsNotMultiPartContent";
# Represents request is not multi part content error.
public type RequestIsNotMultiPartContentError error<REQUEST_IS_NOT_MULTI_PART_CONTENT, ErrorDetail>;

# Identifies request timeout.
public const REQUEST_TIMEOUT = "{ballerinax/aws.s3}RequestTimeout";
# Represents request timeout error.
public type RequestTimeoutError error<REQUEST_TIMEOUT, ErrorDetail>;

# Identifies request time too skewed.
public const REQUEST_TIME_TOO_SKEWED = "{ballerinax/aws.s3}RequestTimeTooSkewed";
# Represents request time too skewed error.
public type RequestTimeTooSkewedError error<REQUEST_TIME_TOO_SKEWED, ErrorDetail>;

# Identifies request torrent of bucket error.
public const REQUEST_TORRENT_OF_BUCKET_ERROR = "{ballerinax/aws.s3}RequestTorrentOfBucketError";
# Represents request torrent of bucket error.
public type RequestTorrentOfBucketError error<REQUEST_TORRENT_OF_BUCKET_ERROR, ErrorDetail>;

# Identifies server side encryption configuration not found error.
public const SERVER_SIDE_ENCRYPTION_CONFIGURATION_NOT_FOUND_ERROR = "{ballerinax/aws.s3}ServerSideEncryptionConfigurationNotFoundError";
# Represents server side encryption configuration not found error.
public type ServerSideEncryptionConfigurationNotFoundError error<SERVER_SIDE_ENCRYPTION_CONFIGURATION_NOT_FOUND_ERROR, ErrorDetail>;

# Identifies server unavailable.
public const SERVICE_UNAVAILABLE = "{ballerinax/aws.s3}ServiceUnavailable";
# Represents server unavailable error.
public type ServiceUnavailableError error<SERVICE_UNAVAILABLE, ErrorDetail>;

# Identifies signature does not match.
public const SIGNATURE_DOES_NOT_MATCH = "{ballerinax/aws.s3}SignatureDoesNotMatch";
# Represents signature does not match error.
public type SignatureDoesNotMatchError error<SIGNATURE_DOES_NOT_MATCH, ErrorDetail>;

# Identifies slow down.
public const SLOW_DOWN = "{ballerinax/aws.s3}SlowDown";
# Represents slow down error.
public type SlowDownError error<SLOW_DOWN, ErrorDetail>;

# Identifies temporary redirect.
public const TEMPORARY_REDIRECT = "{ballerinax/aws.s3}TemporaryRedirect";
# Represents temporary redirect error.
public type TemporaryRedirectError error<TEMPORARY_REDIRECT, ErrorDetail>;

# Identifies token refresh required.
public const TOKEN_REFRESH_REQUIRED = "{ballerinax/aws.s3}TokenRefreshRequired";
# Represents token refresh required error.
public type TokenRefreshRequiredError error<TOKEN_REFRESH_REQUIRED, ErrorDetail>;

# Identifies too many buckets.
public const TOO_MANY_BUCKETS = "{ballerinax/aws.s3}TooManyBuckets";
# Represents too many buckets error.
public type TooManyBucketsError error<TOO_MANY_BUCKETS, ErrorDetail>;

# Identifies unexpected content.
public const UNEXPECTED_CONTENT = "{ballerinax/aws.s3}UnexpectedContent";
# Represents unexpected content error.
public type UnexpectedContentError error<UNEXPECTED_CONTENT, ErrorDetail>;

# Identifies unresolvable grant by email address.
public const UNRESOLVABLE_GRANT_BY_EMAIL_ADDRESS = "{ballerinax/aws.s3}UnresolvableGrantByEmailAddress";
# Represents unresolvable grant by email address error.
public type UnresolvableGrantByEmailAddressError error<UNRESOLVABLE_GRANT_BY_EMAIL_ADDRESS, ErrorDetail>;

# Identifies user key must be specified.
public const USER_KEY_MUST_BE_SPECIFIED = "{ballerinax/aws.s3}UserKeyMustBeSpecified";
# Represents user key must be specified error.
public type UserKeyMustBeSpecifiedError error<USER_KEY_MUST_BE_SPECIFIED, ErrorDetail>;

# Represents Amazons3 related error types.
public type ClientErrorType CLIENT_CONFIG_INITIALIZATION_ERROR | CLIENT_CREDENTIALS_VERIFICATION_ERROR
                            | SIGNATURE_GENERATION_ERROR | HTTP_RESPONSE_HANDLING_ERROR | API_INVOCATION_ERROR;
# Represents Amazons3 related client errors.
public type ClientError ClientCredentialsVerificationError | ClientConfigInitializationError | SignatureGenerationError
                        | ApiInvocationError | HttpResponseHandlingError;

# Represents Amazons3 related bucket operation errors.
public type BucketOperationError AccessDeniedError | AccountProblemError | AllAccessDisabledError
        | AmbiguousGrantByEmailAddressError | AuthorizationHeaderMalformedError | BadDigestError
        | BucketAlreadyExistsError | BucketAlreadyOwnedByYouError | BucketNotEmptyError | CredentialsNotSupportedError
        | CrossLocationLoggingProhibitedError | EntityTooSmallError | EntityTooLargeError | ExpiredTokenError
        | IllegalVersioningConfigurationExceptionError | IncompleteBodyError | IncorrectNumberOfFilesInPostRequestError
        | InlineDataTooLargeError | InternalError | InvalidAccessKeyIdError | InvalidAddressingHeaderError
        | InvalidArgumentError | InvalidBucketNameError | InvalidBucketStateError | InvalidDigestError
        | InvalidEncryptionAlgorithmError | InvalidLocationConstraintError | InvalidObjectStateError | InvalidPartError
        | InvalidPartOrderError | InvalidPayerError | InvalidPolicyDocumentError | InvalidRangeError| InvalidRequestError
        | InvalidSecurityError | InvalidSOAPRequestError | InvalidStorageClassError | InvalidTargetBucketForLoggingError
        | InvalidTokenError | InvalidURIError | KeyTooLongError | MalformedACLError | MalformedPOSTRequestError
        | MalformedXMLError | MaxMessageLengthExceededError | MaxPostPreDataLengthExceededError | MetadataTooLargeError
        | MethodNotAllowedError | MissingAttachmentError | MissingContentLengthError | MissingRequestBodyError
        | MissingSecurityElementError | MissingSecurityHeaderError | NoLoggingStatusForKeyError | NoSuchBucketError
        | NoSuchBucketPolicyError | NoSuchKeyError | NoSuchLifecycleConfigurationError | NoSuchUploadError
        | NoSuchVersionError | NotImplementedError | NotSignedUpError | OperationAbortedError | PermanentRedirectError
        | PreconditionFailedError | RedirectError | RestoreAlreadyInProgressError | RequestIsNotMultiPartContentError
        | RequestTimeoutError | RequestTimeTooSkewedError | RequestTorrentOfBucketError
        | ServerSideEncryptionConfigurationNotFoundError | ServiceUnavailableError | SignatureDoesNotMatchError
        | SlowDownError| TemporaryRedirectError | TokenRefreshRequiredError | TooManyBucketsError | UnexpectedContentError
        | UnresolvableGrantByEmailAddressError | UserKeyMustBeSpecifiedError;

# Identifies unknown server error.
public const UNKNOWN_SERVER_ERROR = "{ballerinax/aws.s3}UnknownServerError";
# Represents unknown server error.
public type UnknownServerError error<UNKNOWN_SERVER_ERROR, ErrorDetail>;

# Ballerina AmazonS3 Union Errors
public type ConnectorError ServerError|ClientError|StringUtilError;

public type ServerError BucketOperationError|UnknownServerError;

# Error messages.
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

# Prepare the `error` as Amazons3 specific `ClientError`.
#
# + errorType - the error type.
# + message - the error message.
# + cause - the `error` instance.
# + return - prepared `s3:ClientError` instance.
public function prepareError(ClientErrorType errorType, string message, error? cause = ()) returns ClientError {
    if (cause is error) {
        error err = error(errorType, message = message, cause = cause);
        return <ClientError> err;
    } else {
        error err = error(errorType, message = message);
        return <ClientError> err;
    }
}
