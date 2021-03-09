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

# Represents client credentials verification error.
public type ClientCredentialsVerificationError distinct error;

# Represents client config initialization error.
public type ClientConfigInitializationError distinct error;

# Represents signature generation error.
public type SignatureGenerationError distinct error;

# Represents API invokation error.
public type ApiInvocationError distinct error;

# Represents http response handling error.
public type HttpResponseHandlingError distinct error;

# Represents string util error.
public type StringUtilError distinct error;

# Represents access denied error.
public type AccessDeniedError distinct error;

# Represents access denied error.
public type AccountProblemError distinct error;

# Represents all access disable error.
public type AllAccessDisabledError distinct error;

# Represents ambiguous grant by email address error.
public type AmbiguousGrantByEmailAddressError distinct error;

# Represents authorization header malformed error.
public type AuthorizationHeaderMalformedError distinct error;

# Represents bad digest error.
public type BadDigestError distinct error;

# Represents bucket already exists error.
public type BucketAlreadyExistsError distinct error;

# Represents bucket already owned by you error.
public type BucketAlreadyOwnedByYouError distinct error;

# Represents bucket not empty error.
public type BucketNotEmptyError distinct error;

# Represents credentials not supported error.
public type CredentialsNotSupportedError distinct error;

# Represents cross location logging prohibited error.
public type CrossLocationLoggingProhibitedError distinct error;

# Represents entry too small error.
public type EntityTooSmallError distinct error;

# Represents entry too large error.
public type EntityTooLargeError distinct error;

# Represents expired token error.
public type ExpiredTokenError distinct error;

# Represents illegal versioning configuration exception error.
public type IllegalVersioningConfigurationExceptionError distinct error;

# Represents incomplete body error.
public type IncompleteBodyError distinct error;

# Represents incorrect number of files in POST request error.
public type IncorrectNumberOfFilesInPostRequestError distinct error;

# Represents inline data too large error.
public type InlineDataTooLargeError distinct error;

# Represents internal error.
public type InternalError distinct error;

# Represents invalid access key id error.
public type InvalidAccessKeyIdError distinct error;

# Represents invalid address header error.
public type InvalidAddressingHeaderError distinct error;

# Represents invalid argument error.
public type InvalidArgumentError distinct error;

# Represents invalid bucket name error.
public type InvalidBucketNameError distinct error;

# Represents invalid bucket state error.
public type InvalidBucketStateError distinct error;

# Represents invalid digest error.
public type InvalidDigestError distinct error;

# Represents invalid encryption algorithm error.
public type InvalidEncryptionAlgorithmError distinct error;

# Represents invalid location constraint error.
public type InvalidLocationConstraintError distinct error;

# Represents invalid object state error.
public type InvalidObjectStateError distinct error;

# Represents invalid part error.
public type InvalidPartError distinct error;

# Represents invalid part order error.
public type InvalidPartOrderError distinct error;

# Represents invalid payer error.
public type InvalidPayerError distinct error;

# Represents invalid policy document error.
public type InvalidPolicyDocumentError distinct error;

# Represents invalid range error.
public type InvalidRangeError distinct error;

# Represents invalid request error.
public type InvalidRequestError distinct error;

# Represents invalid security error.
public type InvalidSecurityError distinct error;

# Represents invalid SOAP request error.
public type InvalidSOAPRequestError distinct error;

# Represents invalid storage class error.
public type InvalidStorageClassError distinct error;

# Represents invalid target bucket for logging error.
public type InvalidTargetBucketForLoggingError distinct error;

# Represents invalid token error.
public type InvalidTokenError distinct error;

# Represents invalid URI error.
public type InvalidURIError distinct error;

# Represents key too long error.
public type KeyTooLongError distinct error;

# Represents malformed ACL error.
public type MalformedACLError distinct error;

# Represents malformed POST request error.
public type MalformedPOSTRequestError distinct error;

# Represents malformed XML error.
public type MalformedXMLError distinct error;

# Represents max message length exceeded error.
public type MaxMessageLengthExceededError distinct error;

# Represents max post pre data length exceeded error.
public type MaxPostPreDataLengthExceededError distinct error;

# Represents meta data too large error.
public type MetadataTooLargeError distinct error;

# Represents method not allowed error.
public type MethodNotAllowedError distinct error;

# Represents missing attachments error.
public type MissingAttachmentError distinct error;

# Represents missing content length error.
public type MissingContentLengthError distinct error;

# Represents missing request body error.
public type MissingRequestBodyError distinct error;

# Represents missing security element error.
public type MissingSecurityElementError distinct error;

# Represents missing security header error.
public type MissingSecurityHeaderError distinct error;

# Represents no logging status for key error.
public type NoLoggingStatusForKeyError distinct error;

# Represents no such bucket error.
public type NoSuchBucketError distinct error;

# Represents no such bucket policy error.
public type NoSuchBucketPolicyError distinct error;

# Represents no such key error.
public type NoSuchKeyError distinct error;

# Represents no such key life cycle configuration error.
public type NoSuchLifecycleConfigurationError distinct error;

# Represents no such upload error.
public type NoSuchUploadError distinct error;

# Represents no such version error.
public type NoSuchVersionError distinct error;

# Represents not implemented error.
public type NotImplementedError distinct error;

# Represents not signed up error.
public type NotSignedUpError distinct error;

# Represents operation aborted error.
public type OperationAbortedError distinct error;

# Represents permanent redirect error.
public type PermanentRedirectError distinct error;

# Represents precondition failed error.
public type PreconditionFailedError distinct error;

# Represents redirect error.
public type RedirectError distinct error;

# Represents restore already in progress error.
public type RestoreAlreadyInProgressError distinct error;

# Represents request is not multi part content error.
public type RequestIsNotMultiPartContentError distinct error;

# Represents request timeout error.
public type RequestTimeoutError distinct error;

# Represents request time too skewed error.
public type RequestTimeTooSkewedError distinct error;

# Represents request torrent of bucket error.
public type RequestTorrentOfBucketError distinct error;

# Represents server side encryption configuration not found error.
public type ServerSideEncryptionConfigurationNotFoundError distinct error;

# Represents server unavailable error.
public type ServiceUnavailableError distinct error;

# Represents signature does not match error.
public type SignatureDoesNotMatchError distinct error;

# Represents slow down error.
public type SlowDownError distinct error;

# Represents temporary redirect error.
public type TemporaryRedirectError distinct error;

# Represents token refresh required error.
public type TokenRefreshRequiredError distinct error;

# Represents too many buckets error.
public type TooManyBucketsError distinct error;

# Represents unexpected content error.
public type UnexpectedContentError distinct error;

# Represents unresolvable grant by email address error.
public type UnresolvableGrantByEmailAddressError distinct error;

# Represents user key must be specified error.
public type UserKeyMustBeSpecifiedError distinct error;

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

# Represents unknown server error.
public type UnknownServerError distinct error;

# Ballerina AmazonS3 Union Errors
public type ConnectorError ServerError|ClientError|StringUtilError;

public type ServerError BucketOperationError|UnknownServerError;

# Error messages.
const string UNKNOWN_SERVER_ERROR_MSG = "Unknown Amazon S3 server error occured.";
const string EMPTY_VALUES_FOR_CREDENTIALS_ERROR_MSG = "Empty values set for accessKeyId or secretAccessKey credential";
const string CLIENT_CREDENTIALS_VERIFICATION_ERROR_MSG = "Error occured while verifying client credentials.";
const string DATE_STRING_GENERATION_ERROR_MSG = "Error occured while generating date strings.";
const string CANONICAL_URI_GENERATION_ERROR_MSG = "Error occured while generating canonical URI.";
const string CANONICAL_QUERY_STRING_GENERATION_ERROR_MSG = "Error occured while generating canonical query string.";
const string STRING_MANUPULATION_ERROR_MSG = "Error occured during string manipulation.";
const string XML_EXTRACTION_ERROR_MSG = "Error occurred while accessing the XML payload from the http response.";
const string API_INVOCATION_ERROR_MSG = "Error occurred while invoking the AmazonS3 API while ";
const string BINARY_CONTENT_EXTRACTION_ERROR_MSG = "Error occured while accessing binary content from the http response";
const string AUTH_HEADER_ERROR_MSG = "Error occured while constructing authorization header";
const string REQUEST_CONTENT_TYPE_ERROR_MSG = "Error occured while accessing content type from the http request";
