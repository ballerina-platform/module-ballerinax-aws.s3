// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

# Static credential configuration
public type StaticAuthConfig record {|
    # The Access Key of the Amazon S3 account
    string accessKeyId;
    # The Secret Access Key of the Amazon S3 account
    string secretAccessKey;
    # Optional session token for temporary credentials
    string sessionToken?;
|};

# Profile-based credential configuration 
public type ProfileAuthConfig record {|
    # AWS shared credentials profile name
    string profileName = "default";
    # Path to the credentials file
    string credentialsFilePath?;
|};

# Represents the default AWS credential chain based authentication.
# Automatically resolves credentials from environment variables, ECS container credentials,
# EC2 instance profiles, and other standard AWS credential sources.
public const DEFAULT_CREDENTIALS = "DEFAULT_CREDENTIALS";

# Authentication configuration
public type AuthConfig StaticAuthConfig|ProfileAuthConfig|DEFAULT_CREDENTIALS;

# Configuration for the AWS S3 Client.
public type ConnectionConfig record {|
    # Authentication configuration
    AuthConfig auth;
     # The AWS Region. If you don't specify an AWS region, Client uses US East as default region
    Region region = US_EAST_1;
|};


# Configuration for creating a bucket.
public type CreateBucketConfig record {|
    # Specifies accessibility for this object (e.g., "private", "public-read")
    CannedACL acl = PRIVATE;
    # Specifies ownership of objects uploaded to this bucket (e.g., "BucketOwnerEnforced", "ObjectWriter")
    ObjectOwnership objectOwnership = BUCKET_OWNER_ENFORCED;
    # Enable Object Lock to prevent objects from being deleted or overwritten
    boolean objectLockEnabled?;
|};

# Defines bucket.
public type Bucket record {
    # The name of the bucket
    string name;
    # The creation date of the bucket
    string creationDate;
    # The AWS region of the bucket
    Region region;
};

# Represents byte[], string, json and xml
public type ContentType byte[]|string|json|xml;

# Configuration for uploading an object.
public type PutObjectConfig record {|
    # The MIME type of the content
    string contentType?;
    # Specifies accessibility for this object (e.g., "private", "public-read")
    CannedACL acl = PRIVATE;
    # The Storage class of the object (e.g., "STANDARD", "GLACIER" for archive, "INTELLIGENT_TIERING")
    StorageClass storageClass = STANDARD;
    # Custom data to attach to the object (e.g., {"author": "John", "project": "demo"})
    map<string> metadata?;
    # Specifies caching behavior along the request/reply chain
    string cacheControl?;
    # Specifies presentational information for the object
    string contentDisposition?;
    # Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field
    string contentEncoding?;
    # The language the content is in (e.g., "en-US", "fr")
    string contentLanguage?;
    # The date and time at which the object is no longer cacheable
    string expires?;
    # Tags for the object
    string tagging?;
    # Encryption type ("AES256" or "aws:kms")
    string serverSideEncryption?;
|};

# Configuration for uploading an object as a stream.
public type PutObjectStreamConfig record {|
    *PutObjectConfig;
    # The Size of the content, in bytes
    int contentLength;
|};

# Configuration for retrieving an object.
public type GetObjectConfig record {|
    # Get a specific version of the object (when versioning is enabled)
    string versionId?;
    # Downloads the specified range bytes of an object
    string range?;
    # Return the object only if its entity tag (ETag) is the same as the one specified
    string ifMatch?;
    # Return the object only if its entity tag (ETag) is different from the one specified
    string ifNoneMatch?;
    # Return the object only if it has been modified since the specified time (e.g., "2024-01-15T00:00:00Z")
    string ifModifiedSince?;
    # Return the object only if it has not been modified since the specified time (e.g., "2024-01-15T00:00:00Z")
    string ifUnmodifiedSince?;
    # The part number of the file part
    int partNumber?;
    # Override the MIME type of the content
    string responseContentType?;
    # Override presentational information for the object
    string responseContentDisposition?;
|};

# Configuration for deleting an object.
public type DeleteObjectConfig record {|
    # Delete a specific version of the object (when versioning is enabled)
    string versionId?;
    # Multi-factor authentication token (needed if MFA Delete is turned on for the bucket)
    string mfa?;
    # Skip the lock protection and delete the object even if it's protected (use with caution)
    boolean bypassGovernanceRetention?;
|};

# Configuration for listing objects.
public type ListObjectsConfig record {|
    # Filter objects that start with this value (e.g., "photos/" for all objects in photos folder)
    string prefix?;
    # Character to group object keys (e.g., "/" to list like folders)
    string delimiter?;
    # Maximum number of objects to return (1-1000)
    int maxKeys?;
    # Token to get the next page of results
    string continuationToken?;
    # List objects after this key name
    string startAfter?;
    # Include owner info in the results
    boolean fetchOwner?;
    # Encoding type for object keys (e.g., "url")
    string encodingType?;
|};

# Configuration for copying an object.
public type CopyObjectConfig record {|
    # Specifies accessibility for the copied object (e.g., "private", "public-read")
    CannedACL acl = PRIVATE;
    # Storage type for the copied object (e.g., "STANDARD", "GLACIER")
    StorageClass storageClass = STANDARD;
    # "COPY" to keep original metadata or "REPLACE" to use new metadata
    string metadataDirective?;
    # New metadata for the copied object (only used when metadataDirective is "REPLACE")
    map<string> metadata?;
    # The MIME type of the copied object
    string contentType?;
    # Specifies caching behavior along the request/reply chain
    string cacheControl?;
    # Specifies presentational information for the object
    string contentDisposition?;
    # Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field
    string contentEncoding?;
    # Tags for the copied object (e.g., "env=prod&team=finance")
    string tagging?;
    # Copy the object only if its entity tag (ETag) is the same as the one specified
    string copySourceIfMatch?;
    # Copy the object only if its entity tag (ETag) is different from the one specified
    string copySourceIfNoneMatch?;
    # Copy the object only if it has been modified since the specified time (e.g., "2024-01-15T00:00:00Z")
    string copySourceIfModifiedSince?;
    # Copy the object only if it has not been modified since the specified time (e.g., "2024-01-15T00:00:00Z")
    string copySourceIfUnmodifiedSince?;
|};

# Configuration for getting object metadata.
public type HeadObjectConfig record {|
    # Get metadata for a specific version of the object (when versioning is enabled)
    string versionId?;
    # The part number of the file part to get metadata for
    int partNumber?;
    # Return the metadata only if its entity tag (ETag) is the same as the one specified
    string ifMatch?;
    # Return the metadata only if its entity tag (ETag) is different from the one specified
    string ifNoneMatch?;
    # Return the metadata only if it has been modified since the specified time
    string ifModifiedSince?;
    # Return the metadata only if it has not been modified since the specified time
    string ifUnmodifiedSince?;
|};

# Configuration for creating presigned URLs.
public type PresignedUrlConfig record {|
    # Specifies how long the URL is valid in minutes (default: 15, max: 10080 for 7 days)
    int expirationMinutes = 15;
    # Specifies what action the URL allows ("GET" to download, "PUT" to upload)
    HttpMethod httpMethod = GET;
    # The MIME type of the content (for PUT requests)
    string contentType?;
    # Specifies presentational information for the object (for GET requests)
    string contentDisposition?;
    # Override file type when downloading (for GET requests)
    string responseContentType?;
    # Get URL for a specific version of the object (when versioning is enabled)
    string versionId?;
|};

# Configuration for multipart upload (for large files uploaded in parts).
public type MultipartUploadConfig record {|
    # The MIME type of the content
    string contentType?;
    # Specifies accessibility for this object (e.g., "private", "public-read")
    CannedACL acl = PRIVATE;
    # The Storage class of the object (e.g., "STANDARD", "GLACIER" for archive)
    StorageClass storageClass = STANDARD;
    # Custom data to attach to the object (e.g., {"author": "John"})
    map<string> metadata?;
    # Specifies caching behavior along the request/reply chain
    string cacheControl?;
    # Specifies presentational information for the object
    string contentDisposition?;
    # Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field
    string contentEncoding?;
    # Tags for the object (e.g., "env=prod&team=finance")
    string tagging?;
    # Encryption type ("AES256" or "aws:kms")
    string serverSideEncryption?;
|};

# Configuration for uploading a single part in a multipart upload.
public type UploadPartConfig record {|
    # Size of the part in bytes
    int contentLength?;
    # MD5 hash of the part content (for data integrity check)
    string contentMD5?;
|};

# Configuration for uploading a part as a stream in a multipart upload.
public type UploadStreamPartConfig record {|
    *UploadPartConfig;
    # Size of the part in bytes
    int contentLength;
|};

# Represents a single S3 object in a listing.
public type S3Object record {|
    # The object's path/name in the bucket (e.g., "photos/image.jpg")
    string key;
    # Size of the object in bytes
    int size;
    # When the object was last changed
    string lastModified;
    # Represents the hash value of the object, which reflects modifications made exclusively to the contents of the object
    string eTag;
    # The Storage class of the object (e.g., "STANDARD", "GLACIER")
    StorageClass storageClass = STANDARD;
|};

# Response from listing objects in a bucket.
public type ListObjectsResponse record {|
    # List of objects found
    S3Object[] objects;
    # Number of objects returned
    int count;
    # True if there are more results (use nextContinuationToken to get them)
    boolean isTruncated;
    # Token to get the next page of results
    string nextContinuationToken?;
|};

# Metadata information about an S3 object.
public type ObjectMetadata record {|
    # The object's path/name in the bucket (e.g., "photos/image.jpg")
    string key;
    # Size of the object in bytes
    int contentLength;
    # The MIME type of the content
    string contentType?;
    # Unique ID of the object's content 
    string eTag;
    # When the object was last changed 
    string lastModified;
    # The Storage class of the object (e.g., "STANDARD", "GLACIER")
    StorageClass storageClass = STANDARD;
    # Version ID of the object (when versioning is enabled)
    string versionId?;
    # Custom data attached to the object
    map<anydata> userMetadata?;
|};

# Represents an AWS Region used by the Amazon S3 client.
public enum Region {
    # Africa (Cape Town)
    AF_SOUTH_1 = "af-south-1",
    # Asia Pacific (Hong Kong)
    AP_EAST_1 = "ap-east-1",
    # Asia Pacific (Taipei)
    AP_EAST_2 = "ap-east-2",
    # Asia Pacific (Tokyo)
    AP_NORTHEAST_1 = "ap-northeast-1",
    # Asia Pacific (Seoul)
    AP_NORTHEAST_2 = "ap-northeast-2",
    # Asia Pacific (Osaka)
    AP_NORTHEAST_3 = "ap-northeast-3",
    # Asia Pacific (Mumbai)
    AP_SOUTH_1 = "ap-south-1",
    # Asia Pacific (Hyderabad)
    AP_SOUTH_2 = "ap-south-2",
    # Asia Pacific (Singapore)
    AP_SOUTHEAST_1 = "ap-southeast-1",
    # Asia Pacific (Sydney)
    AP_SOUTHEAST_2 = "ap-southeast-2",
    # Asia Pacific (Jakarta)
    AP_SOUTHEAST_3 = "ap-southeast-3",
    # Asia Pacific (Melbourne)
    AP_SOUTHEAST_4 = "ap-southeast-4",
    # Asia Pacific (Malaysia)
    AP_SOUTHEAST_5 = "ap-southeast-5",
    # Asia Pacific (New Zealand)
    AP_SOUTHEAST_6 = "ap-southeast-6",
    # Asia Pacific (Thailand)
    AP_SOUTHEAST_7 = "ap-southeast-7",
    # Canada West (Calgary)
    CA_WEST_1 = "ca-west-1",
    # Canada (Central)
    CA_CENTRAL_1 = "ca-central-1",
    # Europe (Frankfurt)
    EU_CENTRAL_1 = "eu-central-1",
    # Europe (Zurich)
    EU_CENTRAL_2 = "eu-central-2",
    # Europe (Stockholm)
    EU_NORTH_1 = "eu-north-1",
    # Europe (Milan)
    EU_SOUTH_1 = "eu-south-1",
    # Europe (Spain)
    EU_SOUTH_2 = "eu-south-2",
    # Europe (Ireland)
    EU_WEST_1 = "eu-west-1",
    # Europe (London)
    EU_WEST_2 = "eu-west-2",
    # Europe (Paris)
    EU_WEST_3 = "eu-west-3",
    # Israel (Tel Aviv)
    IL_CENTRAL_1 = "il-central-1",
    # Mexico (Central)
    MX_CENTRAL_1 = "mx-central-1",
    # Middle East (UAE)
    ME_CENTRAL_1 = "me-central-1",
    # Middle East (Bahrain)
    ME_SOUTH_1 = "me-south-1",
    # South America (São Paulo)
    SA_EAST_1 = "sa-east-1",
    # US East (N. Virginia)
    US_EAST_1 = "us-east-1",
    # US East (Ohio)
    US_EAST_2 = "us-east-2",
    # AWS GovCloud (US-East)
    US_GOV_EAST_1 = "us-gov-east-1",
    # AWS GovCloud (US-West)
    US_GOV_WEST_1 = "us-gov-west-1",
    # US West (N. California)
    US_WEST_1 = "us-west-1",
    # US West (Oregon)
    US_WEST_2 = "us-west-2"
}

# Access control options for buckets and objects.
public enum CannedACL {
    # Only the owner has access
    PRIVATE = "private",
    # Anyone can read
    PUBLIC_READ = "public-read",
    # Anyone can read and write
    PUBLIC_READ_WRITE = "public-read-write",
    # Only authenticated AWS users can read
    AUTHENTICATED_READ = "authenticated-read",
    # EC2 gets read access to GET the object
    AWS_EXEC_READ = "aws-exec-read",
    # Bucket owner can read
    BUCKET_OWNER_READ = "bucket-owner-read",
    # Bucket owner has full control
    BUCKET_OWNER_FULL_CONTROL = "bucket-owner-full-control"
}

# Who owns objects uploaded to the bucket.
public enum ObjectOwnership {
    # Bucket owner owns all objects (recommended, ACLs disabled)
    BUCKET_OWNER_ENFORCED = "BucketOwnerEnforced",
    # The uploader owns the object
    OBJECT_WRITER = "ObjectWriter",
    # Bucket owner owns if uploader grants full control
    BUCKET_OWNER_PREFERRED = "BucketOwnerPreferred"
}

# Storage options for S3 objects (affects cost and access speed).
public enum StorageClass {
    # Default storage for frequently accessed data
    STANDARD = "STANDARD",
    # Lower cost for less critical, reproducible data
    REDUCED_REDUNDANCY = "REDUCED_REDUNDANCY",
    # Lower cost for infrequently accessed data (min 30 days)
    STANDARD_IA = "STANDARD_IA",
    # Lower cost, single availability zone (min 30 days)
    ONEZONE_IA = "ONEZONE_IA",
    # Auto-moves data between tiers based on access patterns
    INTELLIGENT_TIERING = "INTELLIGENT_TIERING",
    # Low cost archive, retrieval takes minutes to hours
    GLACIER = "GLACIER",
    # Archive with instant retrieval (min 90 days)
    GLACIER_IR = "GLACIER_IR",
    # Lowest cost archive, retrieval takes hours (min 180 days)
    DEEP_ARCHIVE = "DEEP_ARCHIVE"
}

# HTTP methods for presigned URLs.
public enum HttpMethod {
    # HTTP GET method
    GET = "GET",
    # HTTP PUT method
    PUT = "PUT"
}
