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

package io.ballerina.lib.aws.s3;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.utils.StringUtils;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.profiles.ProfileFile;

import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.AbortMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.Bucket;
import software.amazon.awssdk.services.s3.model.CompletedMultipartUpload;
import software.amazon.awssdk.services.s3.model.CompletedPart;
import software.amazon.awssdk.services.s3.model.CompleteMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.CopyObjectRequest;
import software.amazon.awssdk.services.s3.model.BucketLocationConstraint;
import software.amazon.awssdk.services.s3.model.CreateBucketConfiguration;
import software.amazon.awssdk.services.s3.model.CreateBucketRequest;
import software.amazon.awssdk.services.s3.model.CreateMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.CreateMultipartUploadResponse;
import software.amazon.awssdk.services.s3.model.DeleteBucketRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetBucketLocationRequest;
import software.amazon.awssdk.services.s3.model.GetBucketLocationResponse;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.HeadObjectResponse;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Response;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Object;
import software.amazon.awssdk.services.s3.model.UploadPartRequest;
import software.amazon.awssdk.services.s3.model.UploadPartResponse;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;

import java.io.InputStream;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Consumer;

public class NativeClientAdaptor {

    private static final String NATIVE_CLIENT = "NATIVE_S3_CLIENT";
    private static final String NATIVE_CONFIG = "NATIVE_CONNECTION_CONFIG";
    public static final BString AUTH = StringUtils.fromString("auth");
    public static final BString REGION = StringUtils.fromString("region");
    public static final BString ACCESS_KEY_ID = StringUtils.fromString("accessKeyId");
    public static final BString PROFILE_NAME = StringUtils.fromString("profileName");
    public static final BString SECRET_ACCESS_KEY = StringUtils.fromString("secretAccessKey");
    public static final BString SESSION_TOKEN = StringUtils.fromString("sessionToken");
    public static final BString CREDENTIALS_FILE_PATH = StringUtils.fromString("credentialsFilePath");
    public static final String ACL = "acl";
    public static final String OBJECT_OWNERSHIP_KEY = "objectOwnership";
    public static final String OBJECT_LOCK_ENABLED_KEY = "objectLockEnabled";
    public static final BString NAME = StringUtils.fromString("name");
    public static final BString CREATION_DATE = StringUtils.fromString("creationDate");
    public static final String US_EAST_1 = "us-east-1";
    public static final String CONTENT_LENGTH_KEY = "contentLength";
    public static final BString CONTENT_LENGTH = StringUtils.fromString(CONTENT_LENGTH_KEY);
    public static final String CONTENT_TYPE = "contentType";
    public static final String STORAGE_CLASS = "storageClass";
    public static final String CACHE_CONTROL = "cacheControl";
    public static final String CONTENT_DISPOSITION = "contentDisposition";
    public static final String CONTENT_ENCODING = "contentEncoding";
    public static final String CONTENT_LANGUAGE = "contentLanguage";
    public static final String TAGGING = "tagging";
    public static final String SERVER_SIDE_ENCRYPTION = "serverSideEncryption";
    public static final String METADATA = "metadata";
    public static final String EXPIRES = "expires";
    public static final String VERSION_ID = "versionId";
    public static final String RANGE = "range";
    public static final String IF_MATCH = "ifMatch";
    public static final String IF_NONE_MATCH = "ifNoneMatch";
    public static final String IF_MODIFIED_SINCE = "ifModifiedSince";
    public static final String IF_UNMODIFIED_SINCE = "ifUnmodifiedSince";
    public static final String PART_NUMBER = "partNumber";
    public static final String RESPONSE_CONTENT_DISPOSITION = "responseContentDisposition";
    public static final String RESPONSE_CONTENT_TYPE = "responseContentType";
    public static final String NATIVE_STREAM = "NATIVE_STREAM";
    public static final String STREAM_ITERATOR = "StreamIterator";
    public static final String MFA = "mfa";
    public static final String BYPASS_GOVERNANCE_RETENTION = "bypassGovernanceRetention";
    public static final String PREFIX = "prefix";
    public static final String DELIMITER = "delimiter";
    public static final String MAX_KEYS = "maxKeys";
    public static final String CONTINUATION_TOKEN = "continuationToken";
    public static final String START_AFTER = "startAfter";
    public static final String FETCH_OWNER = "fetchOwner";
    public static final String ENCODING_TYPE = "encodingType";
    public static final BString KEY = StringUtils.fromString("key");
    public static final BString SIZE = StringUtils.fromString("size");
    public static final BString LAST_MODIFIED = StringUtils.fromString("lastModified");
    public static final BString E_TAG = StringUtils.fromString("eTag");
    public static final String EMPTY_STRING = "";
    public static final String STANDARD = "STANDARD";
    public static final BString OBJECTS = StringUtils.fromString("objects");
    public static final BString COUNT = StringUtils.fromString("count");
    public static final BString IS_TRUNCATED = StringUtils.fromString("isTruncated");
    public static final BString NEXT_CONTINUATION_TOKEN = StringUtils.fromString("nextContinuationToken");
    public static final BString USER_METADATA = StringUtils.fromString("userMetadata");
    public static final String METADATA_DIRECTIVE = "metadataDirective";
    public static final String COPY_SOURCE_IF_MATCH = "copySourceIfMatch";
    public static final String COPY_SOURCE_IF_NONE_MATCH = "copySourceIfNoneMatch";
    public static final String COPY_SOURCE_IF_MODIFIED_SINCE = "copySourceIfModifiedSince";
    public static final String COPY_SOURCE_IF_UNMODIFIED_SINCE = "copySourceIfUnmodifiedSince";
    public static final String CONTENT_MD_5 = "contentMD5";
    public static final BString EXPIRATION_MINUTES = StringUtils.fromString("expirationMinutes");
    public static final BString HTTP_METHOD = StringUtils.fromString("httpMethod");
    public static final String GET = "GET";
    public static final String PUT = "PUT";

    private static Optional<String> getStringConfig(BMap<BString, Object> config, String key) {
        if (config.containsKey(StringUtils.fromString(key))) {
            Object obj = config.get(StringUtils.fromString(key));
            if (obj instanceof BString) {
                String value = ((BString) obj).getValue();
                if (!value.isEmpty()) {
                    return Optional.of(value);
                }
            }
        }
        return Optional.empty();
    }

    private static Optional<Long> getLongConfig(BMap<BString, Object> config, String key) {
        if (config.containsKey(StringUtils.fromString(key))) {
            Object obj = config.get(StringUtils.fromString(key));
            if (obj instanceof Long) {
                return Optional.of((Long) obj);
            }
        }
        return Optional.empty();
    }

    private static Optional<Boolean> getBooleanConfig(BMap<BString, Object> config, String key) {
        if (config.containsKey(StringUtils.fromString(key))) {
            Object obj = config.get(StringUtils.fromString(key));
            if (obj instanceof Boolean) {
                return Optional.of((Boolean) obj);
            }
        }
        return Optional.empty();
    }

    private static Optional<Map<String, String>> getMetadataConfig(BMap<BString, Object> config, String key) {
        if (config.containsKey(StringUtils.fromString(key))) {
            Object metaObj = config.get(StringUtils.fromString(key));
            if (metaObj instanceof BMap) {
                @SuppressWarnings("unchecked")
                BMap<BString, Object> metaMap = (BMap<BString, Object>) metaObj;
                Map<String, String> metadata = new HashMap<>();
                metaMap.entrySet().forEach(entry -> {
                    Object value = entry.getValue();
                    if (value instanceof BString) {
                        metadata.put(entry.getKey().getValue(), ((BString) value).getValue());
                    }
                });
                if (!metadata.isEmpty()) {
                    return Optional.of(metadata);
                }
            }
        }
        return Optional.empty();
    }

    private static void applyStringConfig(BMap<BString, Object> config, String key, Consumer<String> setter) {
        getStringConfig(config, key).ifPresent(setter);
    }

    private static void applyLongConfig(BMap<BString, Object> config, String key, Consumer<Long> setter) {
        getLongConfig(config, key).ifPresent(setter);
    }

    private static void applyBooleanConfig(BMap<BString, Object> config, String key, Consumer<Boolean> setter) {
        getBooleanConfig(config, key).ifPresent(setter);
    }

    private static void applyIntConfig(BMap<BString, Object> config, String key, Consumer<Integer> setter) {
        getLongConfig(config, key).ifPresent(val -> setter.accept(val.intValue()));
    }

    private static void applyMetadataConfig(BMap<BString, Object> config, String key,
            Consumer<Map<String, String>> setter) {
        getMetadataConfig(config, key).ifPresent(setter);
    }

    private static void applyInstantConfig(BMap<BString, Object> config, String key, Consumer<Instant> setter) {
        getStringConfig(config, key).ifPresent(val -> setter.accept(Instant.parse(val)));
    }

    // Client Initialization Method
    public static Object initClient(Environment env, BObject clientObj, BMap<BString, Object> config) {
        try {
            String region = config.getStringValue(REGION).getValue();
            Object authObj = config.get(AUTH);

            if (!(authObj instanceof BMap) && !(authObj instanceof BString)) {
                return ErrorCreator.createError("Invalid auth configuration provided");
            }

            AwsCredentialsProvider credentialsProvider = createCredentialsProvider(authObj);

            S3Client s3Client = S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(credentialsProvider)
                    .crossRegionAccessEnabled(true)
                    .build();

            clientObj.addNativeData(NATIVE_CLIENT, s3Client);
            ConnectionConfig connConfig = new ConnectionConfig(Region.of(region), credentialsProvider);
            clientObj.addNativeData(NATIVE_CONFIG, connConfig);
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    // Close client and release resources
    public static Object closeClient(BObject clientObj) {
        Object nativeClient = clientObj.getNativeData(NATIVE_CLIENT);
        if (nativeClient instanceof S3Client) {
            try {
                ((S3Client) nativeClient).close();
                return null;
            } catch (Exception e) {
                return ErrorCreator.createError(e);
            } finally {
                clientObj.addNativeData(NATIVE_CLIENT, null);
            }
        }
        return null;
    }

    // Method for credentials provider based on auth config
    @SuppressWarnings("unchecked")
    private static AwsCredentialsProvider createCredentialsProvider(Object auth) {
        if (auth instanceof BString) {
            return DefaultCredentialsProvider.create();
        } else if (auth instanceof BMap) {
            BMap<BString, Object> authMap = (BMap<BString, Object>) auth;
            if (authMap.containsKey(ACCESS_KEY_ID)) {
                return createStaticCredentialsProvider(authMap);
            } else if (authMap.containsKey(PROFILE_NAME)) {
                return createProfileCredentialsProvider(authMap);
            }
        }
        throw new IllegalArgumentException("Unsupported auth configuration");
    }

    // Handle static credentials with optional session token
    private static AwsCredentialsProvider createStaticCredentialsProvider(BMap<BString, Object> auth) {
        String accessKeyId = auth.getStringValue(ACCESS_KEY_ID).getValue();
        String secretAccessKey = auth.getStringValue(SECRET_ACCESS_KEY).getValue();

        AwsCredentials credentials;
        if (auth.containsKey(SESSION_TOKEN)) {
            Object sessionTokenObj = auth.get(SESSION_TOKEN);
            if (sessionTokenObj instanceof BString) {
                String sessionToken = ((BString) sessionTokenObj).getValue();
                credentials = (!sessionToken.isEmpty())
                        ? AwsSessionCredentials.create(accessKeyId, secretAccessKey, sessionToken)
                        : AwsBasicCredentials.create(accessKeyId, secretAccessKey);
            } else {
                credentials = AwsBasicCredentials.create(accessKeyId, secretAccessKey);
            }
        } else {
            credentials = AwsBasicCredentials.create(accessKeyId, secretAccessKey);
        }
        return StaticCredentialsProvider.create(credentials);
    }

    // Handle profile-based credentials with optional custom file path
    private static AwsCredentialsProvider createProfileCredentialsProvider(BMap<BString, Object> auth) {
        String profileName = auth.getStringValue(PROFILE_NAME).getValue();

        if (auth.containsKey(CREDENTIALS_FILE_PATH)) {
            Object credentialsFilePathObj = auth.get(CREDENTIALS_FILE_PATH);
            if (credentialsFilePathObj instanceof BString) {
                String credentialsFilePath = ((BString) credentialsFilePathObj).getValue();
                if (!credentialsFilePath.isEmpty()) {
                    ProfileFile profileFile = ProfileFile.builder()
                            .content(java.nio.file.Paths.get(credentialsFilePath))
                            .type(ProfileFile.Type.CREDENTIALS)
                            .build();
                    return ProfileCredentialsProvider.builder()
                            .profileFile(profileFile)
                            .profileName(profileName)
                            .build();
                }
            }
        }

        return ProfileCredentialsProvider.create(profileName);
    }

    private static Object getClient(BObject clientObj) {
        S3Client client = (S3Client) clientObj.getNativeData(NATIVE_CLIENT);
        if (client == null) {
            return ErrorCreator.createError("S3 Client is not initialized");
        }
        return client;
    }

    private static Object getConnectionConfig(BObject clientObj) {
        ConnectionConfig config = (ConnectionConfig) clientObj.getNativeData(NATIVE_CONFIG);
        if (config == null) {
            return ErrorCreator.createError("S3 Connection Config is not initialized");
        }
        return config;
    }

    // Bucket Operations

    public static Object createBucket(BObject clientObj, BString bucketName, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        String bucket = bucketName.getValue();
        try {
            CreateBucketRequest.Builder builder = CreateBucketRequest.builder().bucket(bucket);

            applyStringConfig(config, ACL, builder::acl);
            applyStringConfig(config, OBJECT_OWNERSHIP_KEY, builder::objectOwnership);
            applyBooleanConfig(config, OBJECT_LOCK_ENABLED_KEY, builder::objectLockEnabledForBucket);

            Object configOrError = getConnectionConfig(clientObj);
            if (configOrError instanceof ConnectionConfig connectionConfig
                    && connectionConfig.region != null
                    && !Region.US_EAST_1.equals(connectionConfig.region)) {
                builder.createBucketConfiguration(CreateBucketConfiguration.builder()
                        .locationConstraint(BucketLocationConstraint.fromValue(connectionConfig.region.id()))
                        .build());
            }

            s3.createBucket(builder.build());

            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object deleteBucket(BObject clientObj, BString bucket) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            s3.deleteBucket(DeleteBucketRequest.builder().bucket(bucket.getValue()).build());
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    @SuppressWarnings("unchecked")
    public static Object listBuckets(BObject clientObj) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            List<Bucket> buckets = s3.listBuckets().buckets();
            MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
            BMap<BString, Object>[] bBuckets = new BMap[buckets.size()];

            for (int i = 0; i < buckets.size(); i++) {
                Bucket bucket = buckets.get(i);
                BMap<BString, Object> bucketRecord = ValueCreator.createMapValue(mapType);

                bucketRecord.put(NAME, StringUtils.fromString(bucket.name()));

                Instant creationDate = bucket.creationDate();
                String creationDateStr = creationDate != null ? creationDate.toString() : EMPTY_STRING;
                bucketRecord.put(CREATION_DATE, StringUtils.fromString(creationDateStr));

                bBuckets[i] = bucketRecord;
            }
            return ValueCreator.createArrayValue(bBuckets,
                    TypeCreator.createArrayType(PredefinedTypes.TYPE_JSON));
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object getBucketLocation(BObject clientObj, BString bucket) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            GetBucketLocationRequest request = GetBucketLocationRequest.builder()
                    .bucket(bucket.getValue())
                    .build();
            GetBucketLocationResponse response = s3.getBucketLocation(request);
            String location = response.locationConstraintAsString();
            return StringUtils.fromString(location != null ? location : US_EAST_1);
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    // Object Operations

    public static Object putObjectFromFile(BObject clientObj, BString bucket, BString key, BString filePath,
            BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            PutObjectRequest.Builder builder = PutObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyPutObjectConfig(builder, config);

            s3.putObject(builder.build(), RequestBody.fromFile(java.nio.file.Paths.get(filePath.getValue())));
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object putObjectWithContent(BObject clientObj, BString bucket, BString key, BArray content,
            BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            PutObjectRequest.Builder builder = PutObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyPutObjectConfig(builder, config);

            s3.putObject(builder.build(), RequestBody.fromBytes(content.getBytes()));
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object putObjectWithStream(Environment env, BObject clientObj, BString bucket, BString key,
            BStream contentStream, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            long contentLength = config.getIntValue(CONTENT_LENGTH);

            // Validate contentLength is positive
            if (contentLength <= 0) {
                return ErrorCreator.createError(
                        "contentLength must be a positive value, got: " + contentLength);
            }

            PutObjectRequest.Builder builder = PutObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .contentLength(contentLength);
            applyPutObjectConfig(builder, config);

            try (InputStream inputStream = new BallerinaStreamInputStream(env, contentStream)) {
                s3.putObject(builder.build(), RequestBody.fromInputStream(inputStream, contentLength));
            }

            return null;

        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    private static void applyPutObjectConfig(PutObjectRequest.Builder builder, BMap<BString, Object> config) {
        applyStringConfig(config, CONTENT_TYPE, builder::contentType);
        applyStringConfig(config, ACL, builder::acl);
        applyStringConfig(config, STORAGE_CLASS, builder::storageClass);
        applyStringConfig(config, CACHE_CONTROL, builder::cacheControl);
        applyStringConfig(config, CONTENT_DISPOSITION, builder::contentDisposition);
        applyStringConfig(config, CONTENT_ENCODING, builder::contentEncoding);
        applyStringConfig(config, CONTENT_LANGUAGE, builder::contentLanguage);
        applyStringConfig(config, TAGGING, builder::tagging);
        applyStringConfig(config, SERVER_SIDE_ENCRYPTION, builder::serverSideEncryption);
        applyMetadataConfig(config, METADATA, builder::metadata);
        applyInstantConfig(config, EXPIRES, builder::expires);
    }

    public static Object getObjectAsStream(Environment env, BObject clientObj, BString bucket, BString key,
            BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            GetObjectRequest.Builder builder = GetObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, VERSION_ID, builder::versionId);
            applyStringConfig(config, RANGE, builder::range);
            applyStringConfig(config, IF_MATCH, builder::ifMatch);
            applyStringConfig(config, IF_NONE_MATCH, builder::ifNoneMatch);
            applyInstantConfig(config, IF_MODIFIED_SINCE, builder::ifModifiedSince);
            applyInstantConfig(config, IF_UNMODIFIED_SINCE, builder::ifUnmodifiedSince);
            applyIntConfig(config, PART_NUMBER, builder::partNumber);
            applyStringConfig(config, RESPONSE_CONTENT_DISPOSITION, builder::responseContentDisposition);
            applyStringConfig(config, RESPONSE_CONTENT_TYPE, builder::responseContentType);

            ResponseInputStream<GetObjectResponse> s3Stream = s3.getObject(builder.build());
            BObject streamWrapper = ValueCreator.createObjectValue(env.getCurrentModule(), STREAM_ITERATOR);
            streamWrapper.addNativeData(NATIVE_STREAM, s3Stream);
            return streamWrapper;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object getObject(BObject clientObj, BString bucket, BString key,
            BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            GetObjectRequest.Builder builder = GetObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, VERSION_ID, builder::versionId);
            applyStringConfig(config, RANGE, builder::range);
            applyStringConfig(config, IF_MATCH, builder::ifMatch);
            applyStringConfig(config, IF_NONE_MATCH, builder::ifNoneMatch);
            applyInstantConfig(config, IF_MODIFIED_SINCE, builder::ifModifiedSince);
            applyInstantConfig(config, IF_UNMODIFIED_SINCE, builder::ifUnmodifiedSince);
            applyIntConfig(config, PART_NUMBER, builder::partNumber);
            applyStringConfig(config, RESPONSE_CONTENT_DISPOSITION, builder::responseContentDisposition);
            applyStringConfig(config, RESPONSE_CONTENT_TYPE, builder::responseContentType);

            ResponseBytes<GetObjectResponse> responseBytes = s3.getObjectAsBytes(builder.build());
            byte[] bytes = responseBytes.asByteArray();

            return ValueCreator.createArrayValue(bytes);
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object deleteObject(BObject clientObj, BString bucket, BString key, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            DeleteObjectRequest.Builder builder = DeleteObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, VERSION_ID, builder::versionId);
            applyStringConfig(config, MFA, builder::mfa);
            applyBooleanConfig(config, BYPASS_GOVERNANCE_RETENTION, builder::bypassGovernanceRetention);

            s3.deleteObject(builder.build());
            return null;
        } catch (NoSuchKeyException e) {
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    @SuppressWarnings("unchecked")
    public static Object listObjectsV2(BObject clientObj, BString bucket, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            ListObjectsV2Request.Builder builder = ListObjectsV2Request.builder()
                    .bucket(bucket.getValue());

            applyStringConfig(config, PREFIX, builder::prefix);
            applyStringConfig(config, DELIMITER, builder::delimiter);
            applyIntConfig(config, MAX_KEYS, builder::maxKeys);
            applyStringConfig(config, CONTINUATION_TOKEN, builder::continuationToken);
            applyStringConfig(config, START_AFTER, builder::startAfter);
            applyBooleanConfig(config, FETCH_OWNER, builder::fetchOwner);
            applyStringConfig(config, ENCODING_TYPE, builder::encodingType);

            ListObjectsV2Response response = s3.listObjectsV2(builder.build());
            MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
            BMap<BString, Object> result = ValueCreator.createMapValue(mapType);
            List<S3Object> objects = response.contents();
            int size = objects.size();

            // Create array of S3Object maps
            BMap<BString, Object>[] objArray = new BMap[size];
            for (int i = 0; i < size; i++) {
                S3Object obj = objects.get(i);
                BMap<BString, Object> objMap = ValueCreator.createMapValue(mapType);

                objMap.put(KEY, StringUtils.fromString(obj.key()));
                objMap.put(SIZE, obj.size());
                String lastModified = obj.lastModified() != null ? obj.lastModified().toString() : EMPTY_STRING;
                objMap.put(LAST_MODIFIED, StringUtils.fromString(lastModified));
                String eTag = obj.eTag() != null ? obj.eTag() : EMPTY_STRING;
                objMap.put(E_TAG, StringUtils.fromString(eTag));
                String storageClass = obj.storageClassAsString() != null ? obj.storageClassAsString() : STANDARD;
                objMap.put(StringUtils.fromString(STORAGE_CLASS), StringUtils.fromString(storageClass));

                objArray[i] = objMap;
            }

            // Convert array to BArray using ValueCreator
            BArray objectsArray = ValueCreator.createArrayValue(objArray,
                    TypeCreator.createArrayType(PredefinedTypes.TYPE_JSON));

            result.put(OBJECTS, objectsArray);
            result.put(COUNT, (long) size);
            result.put(IS_TRUNCATED, response.isTruncated());

            if (response.nextContinuationToken() != null) {
                result.put(NEXT_CONTINUATION_TOKEN, StringUtils.fromString(response.nextContinuationToken()));
            }

            return result;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object headObject(BObject clientObj, BString bucket, BString key, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            HeadObjectRequest.Builder builder = HeadObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, VERSION_ID, builder::versionId);
            applyIntConfig(config, PART_NUMBER, builder::partNumber);
            applyStringConfig(config, IF_MATCH, builder::ifMatch);
            applyStringConfig(config, IF_NONE_MATCH, builder::ifNoneMatch);
            applyInstantConfig(config, IF_MODIFIED_SINCE, builder::ifModifiedSince);
            applyInstantConfig(config, IF_UNMODIFIED_SINCE, builder::ifUnmodifiedSince);

            HeadObjectResponse response = s3.headObject(builder.build());
            MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
            BMap<BString, Object> metadata = ValueCreator.createMapValue(mapType);

            metadata.put(KEY, key);
            metadata.put(CONTENT_LENGTH, response.contentLength());
            if (response.contentType() != null) {
                metadata.put(StringUtils.fromString(CONTENT_TYPE), StringUtils.fromString(response.contentType()));
            }
            if (response.eTag() != null) {
                metadata.put(E_TAG, StringUtils.fromString(response.eTag()));
            }
            if (response.lastModified() != null) {
                metadata.put(LAST_MODIFIED,
                        StringUtils.fromString(response.lastModified().toString()));
            }
            String storageClass = response.storageClassAsString();
            metadata.put(StringUtils.fromString(STORAGE_CLASS),
                    StringUtils.fromString(storageClass != null ? storageClass : STANDARD));
            if (response.versionId() != null) {
                metadata.put(StringUtils.fromString(VERSION_ID), StringUtils.fromString(response.versionId()));
            }

            if (response.metadata() != null && !response.metadata().isEmpty()) {
                BMap<BString, Object> userMeta = ValueCreator.createMapValue(mapType);
                response.metadata()
                        .forEach((k, v) -> userMeta.put(StringUtils.fromString(k), StringUtils.fromString(v)));
                metadata.put(USER_METADATA, userMeta);
            }

            return metadata;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object copyObject(BObject clientObj, BString sourceBucket, BString sourceKey, BString destBucket,
            BString destKey, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            CopyObjectRequest.Builder builder = CopyObjectRequest.builder()
                    .sourceBucket(sourceBucket.getValue())
                    .sourceKey(sourceKey.getValue())
                    .destinationBucket(destBucket.getValue())
                    .destinationKey(destKey.getValue());

            applyStringConfig(config, ACL, builder::acl);
            applyStringConfig(config, STORAGE_CLASS, builder::storageClass);
            applyStringConfig(config, METADATA_DIRECTIVE, builder::metadataDirective);
            applyStringConfig(config, CONTENT_TYPE, builder::contentType);
            applyMetadataConfig(config, METADATA, builder::metadata);
            applyStringConfig(config, CACHE_CONTROL, builder::cacheControl);
            applyStringConfig(config, CONTENT_DISPOSITION, builder::contentDisposition);
            applyStringConfig(config, CONTENT_ENCODING, builder::contentEncoding);
            applyStringConfig(config, TAGGING, builder::tagging);
            applyStringConfig(config, COPY_SOURCE_IF_MATCH, builder::copySourceIfMatch);
            applyStringConfig(config, COPY_SOURCE_IF_NONE_MATCH, builder::copySourceIfNoneMatch);
            applyInstantConfig(config, COPY_SOURCE_IF_MODIFIED_SINCE, builder::copySourceIfModifiedSince);
            applyInstantConfig(config, COPY_SOURCE_IF_UNMODIFIED_SINCE, builder::copySourceIfUnmodifiedSince);

            s3.copyObject(builder.build());
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object doesObjectExist(BObject clientObj, BString bucket, BString key) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            HeadObjectRequest request = HeadObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .build();
            s3.headObject(request);
            return true;
        } catch (NoSuchKeyException e) {
            return false;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    // Multipart Upload Operations

    public static Object createMultipartUpload(BObject clientObj, BString bucket, BString key,
            BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            CreateMultipartUploadRequest.Builder builder = CreateMultipartUploadRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyMultipartConfig(builder, config);

            CreateMultipartUploadResponse response = s3.createMultipartUpload(builder.build());
            return StringUtils.fromString(response.uploadId());
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    private static void applyMultipartConfig(CreateMultipartUploadRequest.Builder builder,
            BMap<BString, Object> config) {
        applyStringConfig(config, CONTENT_TYPE, builder::contentType);
        applyStringConfig(config, ACL, builder::acl);
        applyStringConfig(config, STORAGE_CLASS, builder::storageClass);
        applyStringConfig(config, TAGGING, builder::tagging);
        applyStringConfig(config, SERVER_SIDE_ENCRYPTION, builder::serverSideEncryption);
        applyMetadataConfig(config, METADATA, builder::metadata);
        applyStringConfig(config, CACHE_CONTROL, builder::cacheControl);
        applyStringConfig(config, CONTENT_DISPOSITION, builder::contentDisposition);
        applyStringConfig(config, CONTENT_ENCODING, builder::contentEncoding);
    }

    public static Object uploadPart(BObject clientObj, BString bucket, BString key, BString uploadId,
            long partNumber, BArray content, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            if (partNumber < 1 || partNumber > 10000) {
                return ErrorCreator.createError("Part number must be between 1 and 10000, got: " + partNumber);
            }
            byte[] contentBytes = content.getBytes();

            UploadPartRequest.Builder builder = UploadPartRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .uploadId(uploadId.getValue())
                    .partNumber((int) partNumber);

            applyLongConfig(config, CONTENT_LENGTH_KEY, builder::contentLength);
            applyStringConfig(config, CONTENT_MD_5, builder::contentMD5);

            UploadPartRequest request = builder.build();
            UploadPartResponse response = s3.uploadPart(request, RequestBody.fromBytes(contentBytes));

            return StringUtils.fromString(response.eTag());
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object uploadPartWithStream(Environment env, BObject clientObj, BString bucket, BString key,
            BString uploadId, long partNumber, BStream contentStream, BMap<BString, Object> config) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            if (partNumber < 1 || partNumber > 10000) {
                return ErrorCreator.createError("Part number must be between 1 and 10000, got: " + partNumber);
            }
            long contentLength = config.getIntValue(CONTENT_LENGTH);

            if (contentLength <= 0) {
                return ErrorCreator.createError("contentLength must be a positive value, got: " + contentLength);
            }

            UploadPartRequest.Builder builder = UploadPartRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .uploadId(uploadId.getValue())
                    .partNumber((int) partNumber)
                    .contentLength(contentLength);

            applyStringConfig(config, CONTENT_MD_5, builder::contentMD5);

            try (InputStream inputStream = new BallerinaStreamInputStream(env, contentStream)) {
                UploadPartResponse response = s3.uploadPart(builder.build(),
                        RequestBody.fromInputStream(inputStream, contentLength));
                return StringUtils.fromString(response.eTag());
            }
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object completeMultipartUpload(BObject clientObj, BString bucket, BString key, BString uploadId,
            BArray partNumbers, BArray etags) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            long[] pNums = partNumbers.getIntArray();
            String[] eTagsStr = etags.getStringArray();

            if (pNums.length != eTagsStr.length) {
                return ErrorCreator.createError(
                        "partNumbers and etags arrays must have the same length. Got: " +
                        pNums.length + " vs " + eTagsStr.length);
            }

            List<CompletedPart> parts = new ArrayList<>();

            for (int i = 0; i < pNums.length; i++) {
                if (pNums[i] < 1 || pNums[i] > 10000) {
                    return ErrorCreator.createError(
                            "Part number must be between 1 and 10000, got: " + pNums[i]);
                }
                parts.add(CompletedPart.builder()
                        .partNumber((int) pNums[i])
                        .eTag(eTagsStr[i])
                        .build());
            }

            CompletedMultipartUpload completedMultipartUpload = CompletedMultipartUpload.builder()
                    .parts(parts)
                    .build();

            CompleteMultipartUploadRequest request = CompleteMultipartUploadRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .uploadId(uploadId.getValue())
                    .multipartUpload(completedMultipartUpload)
                    .build();

            s3.completeMultipartUpload(request);
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object abortMultipartUpload(BObject clientObj, BString bucket, BString key, BString uploadId) {
        Object clientOrError = getClient(clientObj);
        if (clientOrError instanceof BError) {
            return clientOrError;
        }
        @SuppressWarnings("resource")
        S3Client s3 = (S3Client) clientOrError;
        try {
            AbortMultipartUploadRequest request = AbortMultipartUploadRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .uploadId(uploadId.getValue())
                    .build();

            s3.abortMultipartUpload(request);
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    // Presigned URL Operations

    public static Object createPresignedUrl(BObject clientObj, BString bucket, BString key,
            BMap<BString, Object> config) {
        S3Presigner presigner = null;

        try {
            long expirationMinutes = config.getIntValue(EXPIRATION_MINUTES);

            Object methodObj = config.get(HTTP_METHOD);
            String httpMethod = (methodObj instanceof BString method)
                    ? method.getValue().toUpperCase()
                    : GET;

            Object connOrError = getConnectionConfig(clientObj);
            if (connOrError instanceof BError) {
                return connOrError;
            }
            ConnectionConfig connConfig = (ConnectionConfig) connOrError;

            presigner = S3Presigner.builder()
                    .region(connConfig.region)
                    .credentialsProvider(connConfig.credentialsProvider)
                    .build();

            String preSignedUrl = GET.equals(httpMethod)
                    ? generateGetPresignedUrl(presigner, bucket.getValue(), key.getValue(), expirationMinutes, config)
                    : PUT.equals(httpMethod)
                            ? generatePutPresignedUrl(presigner, bucket.getValue(), key.getValue(), expirationMinutes,
                                    config)
                            : null;
            if (preSignedUrl == null) {
                return ErrorCreator.createError(
                        "Unsupported HTTP method: " + httpMethod + ". Supported methods: GET, PUT");
            }
            return StringUtils.fromString(preSignedUrl);
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        } finally {
            if (presigner != null) {
                presigner.close();
            }
        }
    }

    private static String generateGetPresignedUrl(S3Presigner presigner, String bucket, String key,
            long expirationMinutes, BMap<BString, Object> config) {

        GetObjectRequest.Builder getBuilder = GetObjectRequest.builder()
                .bucket(bucket)
                .key(key);

        applyStringConfig(config, VERSION_ID, getBuilder::versionId);
        applyStringConfig(config, RESPONSE_CONTENT_TYPE, getBuilder::responseContentType);
        applyStringConfig(config, CONTENT_DISPOSITION, getBuilder::responseContentDisposition);

        GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
                .signatureDuration(Duration.ofMinutes(expirationMinutes))
                .getObjectRequest(getBuilder.build())
                .build();

        PresignedGetObjectRequest presignedRequest = presigner.presignGetObject(presignRequest);
        return presignedRequest.url().toString();
    }

    private static String generatePutPresignedUrl(S3Presigner presigner, String bucket, String key,
            long expirationMinutes, BMap<BString, Object> config) {

        PutObjectRequest.Builder putBuilder = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key);

        applyStringConfig(config, CONTENT_TYPE, putBuilder::contentType);
        applyStringConfig(config, CONTENT_DISPOSITION, putBuilder::contentDisposition);

        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(Duration.ofMinutes(expirationMinutes))
                .putObjectRequest(putBuilder.build())
                .build();

        PresignedPutObjectRequest presignedRequest = presigner.presignPutObject(presignRequest);
        return presignedRequest.url().toString();
    }
}
