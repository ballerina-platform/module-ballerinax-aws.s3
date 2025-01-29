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

// String constants.
const string UTF_8 = "UTF-8";
const string UNSIGNED_PAYLOAD = "UNSIGNED-PAYLOAD";
const string SERVICE_NAME = "s3";
const string TERMINATION_STRING = "aws4_request";
const string AWS4_HMAC_SHA256 = "AWS4-HMAC-SHA256";
const string CREDENTIAL = "Credential";
const string SIGNED_HEADER = " SignedHeaders";
const string SIGNATURE = " Signature";
const string AWS4 = "AWS4";
const string ISO8601_BASIC_DATE_FORMAT = "yyyyMMdd'T'HHmmss'Z'";
const string SHORT_DATE_FORMAT = "yyyyMMdd";
const string ENCODED_SLASH = "%2F";
const string SLASH = "/";
const string EMPTY_STRING = "";

// Constants to refer the headers.
const string CONTENT_TYPE = "Content-Type";
const string X_AMZ_CONTENT_SHA256 = "X-Amz-Content-Sha256";
const string X_AMZ_DATE = "X-Amz-Date";
const string HOST = "Host";
const string X_AMZ_ACL = "x-amz-acl";
const string X_AMZ_MFA = "x-amz-mfa";
const string X_AWS_EC2_METADATA_TOKEN = "X-aws-ec2-metadata-token";
const string X_AWS_EC2_METADATA_TOKEN_TTL_SECONDS = "X-aws-ec2-metadata-token-ttl-seconds";
const string CACHE_CONTROL = "Cache-Control";
const string CONTENT_DISPOSITION = "Content-Disposition";
const string CONTENT_ENCODING = "Content-Encoding";
const string CONTENT_LENGTH = "Content-Length";
const string CONTENT_MD5 = "Content-MD5";
const string EXPECT = "Expect";
const string EXPIRES = "Expires";
const string IF_MODIFIED_SINCE = "If-Modified-Since";
const string IF_UNMODIFIED_SINCE = "If-Unmodified-Since";
const string IF_MATCH = "If-Match";
const string IF_NONE_MATCH = "If-None-Match";
const string RANGE = "Range";
const string AUTHORIZATION = "Authorization";
const X_AMZ_EXPIRES = "X-Amz-Expires";
const X_AMZ_ALGORITHM = "X-Amz-Algorithm";
const X_AMZ_CREDENTIAL = "X-Amz-Credential";
const X_AMZ_SIGNED_HEADERS = "X-Amz-SignedHeaders";
const X_AMZ_SIGNATURE = "X-Amz-Signature";
const X_AMZ_SECURITY_TOKEN = "X-amz-security-token";

// HTTP verbs.
const string GET = "GET";
const string PUT = "PUT";
const POST = "POST";
const string DELETE = "DELETE";
const string TRUE = "TRUE";
const string FALSE = "FALSE";
const string HTTPS = "https://";

const string AMAZON_AWS_HOST = "s3.amazonaws.com";
const string DEFAULT_REGION = "us-east-1";
const string ERROR_REASON_PREFIX = "{ballerinax/aws.s3}";

# IAM role related constants.
const string METADATA_TOKEN_URL = "http://169.254.169.254/latest/api/token";
const string METADATA_BASE_URL = "http://169.254.169.254/latest/meta-data/iam/security-credentials";

# Error messages.
const string EMPTY_VALUES_FOR_CREDENTIALS_ERROR_MSG = "Empty values set for accessKeyId or secretAccessKey credential";
const string DATE_STRING_GENERATION_ERROR_MSG = "Error occured while generating date strings.";
const string CANONICAL_URI_GENERATION_ERROR_MSG = "Error occured while generating canonical URI.";
const string CANONICAL_QUERY_STRING_GENERATION_ERROR_MSG = "Error occured while generating canonical query string.";
const string XML_EXTRACTION_ERROR_MSG = "Error occurred while accessing the XML payload from the http response.";
const string BINARY_CONTENT_EXTRACTION_ERROR_MSG = "Error occured while accessing binary content from the http response";
const EXPIRATION_TIME_ERROR_MSG = "Invalid expiration time. Expiration time should be a positive integer.";
const EMPTY_OBJECT_NAME_ERROR_MSG = "Invalid object name. Object name should not be empty.";
const EMPTY_BUCKET_NAME_ERROR_MSG = "Invalid bucket name. Bucket name should not be empty.";

# The action to be carried out on the object.
public enum ObjectAction {
    # Create a new object
    CREATE,
    # Retrieve an existing object
    RETRIEVE
};
