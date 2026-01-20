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
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.api.utils.StringUtils;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
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

    @SuppressWarnings("unchecked")
    private static Optional<Map<String, String>> getMetadataConfig(BMap<BString, Object> config, String key) {
        if (config.containsKey(StringUtils.fromString(key))) {
            Object metaObj = config.get(StringUtils.fromString(key));
            if (metaObj instanceof BMap) {
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
    @SuppressWarnings("unchecked")
    public static Object initClient(Environment env, BObject clientObj, BMap<BString, Object> config) {
        try {
            ErrorCreator.initModule(env);

            String region = config.getStringValue(StringUtils.fromString("region")).getValue();
            Object authObj = config.get(StringUtils.fromString("auth"));

            if (!(authObj instanceof BMap)) {
                return ErrorCreator.createError("Invalid auth configuration provided");
            }

            BMap<BString, Object> auth = (BMap<BString, Object>) authObj;
            AwsCredentialsProvider credentialsProvider = createCredentialsProvider(auth);

            S3Client s3Client = S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(credentialsProvider)
                    .build();

            clientObj.addNativeData(NATIVE_CLIENT, s3Client);
            ConnectionConfig connConfig = new ConnectionConfig(Region.of(region), credentialsProvider);
            clientObj.addNativeData(NATIVE_CONFIG, connConfig);
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    // Method for credentials provider based on auth config
    private static AwsCredentialsProvider createCredentialsProvider(BMap<BString, Object> auth) {
        if (auth.containsKey(StringUtils.fromString("accessKeyId"))) {
            return createStaticCredentialsProvider(auth);
        } else if (auth.containsKey(StringUtils.fromString("profileName"))) {
            return createProfileCredentialsProvider(auth);
        } else {
            throw new IllegalArgumentException("Unsupported auth configuration");
        }
    }

    // Handle static credentials with optional session token
    private static AwsCredentialsProvider createStaticCredentialsProvider(BMap<BString, Object> auth) {
        String accessKeyId = auth.getStringValue(StringUtils.fromString("accessKeyId")).getValue();
        String secretAccessKey = auth.getStringValue(StringUtils.fromString("secretAccessKey")).getValue();

        AwsCredentials credentials;
        if (auth.containsKey(StringUtils.fromString("sessionToken"))) {
            Object sessionTokenObj = auth.get(StringUtils.fromString("sessionToken"));
            if (sessionTokenObj instanceof BString) {
                String sessionToken = ((BString) sessionTokenObj).getValue();
                if (!sessionToken.isEmpty()) {
                    credentials = AwsSessionCredentials.create(accessKeyId, secretAccessKey, sessionToken);
                } else {
                    credentials = AwsBasicCredentials.create(accessKeyId, secretAccessKey);
                }
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
        String profileName = auth.getStringValue(StringUtils.fromString("profileName")).getValue();

        if (auth.containsKey(StringUtils.fromString("credentialsFilePath"))) {
            Object credentialsFilePathObj = auth.get(StringUtils.fromString("credentialsFilePath"));
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

    private static S3Client getClient(BObject clientObj) {
        S3Client client = (S3Client) clientObj.getNativeData(NATIVE_CLIENT);
        if (client == null) {
            throw ErrorCreator.createError("S3 Client is not initialized");
        }
        return client;
    }

    private static ConnectionConfig getConnectionConfig(BObject clientObj) {
        ConnectionConfig config = (ConnectionConfig) clientObj.getNativeData(NATIVE_CONFIG);
        if (config == null) {
            throw ErrorCreator.createError("S3 Connection Config is not initialized");
        }
        return config;
    }

    // Bucket Operations

    public static Object createBucket(BObject clientObj, BString bucketName, BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        String bucket = bucketName.getValue();
        try {
            CreateBucketRequest.Builder builder = CreateBucketRequest.builder().bucket(bucket);

            applyStringConfig(config, "acl", builder::acl);
            applyStringConfig(config, "objectOwnership", builder::objectOwnership);
            applyBooleanConfig(config, "objectLockEnabled", builder::objectLockEnabledForBucket);

            s3.createBucket(builder.build());

            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object deleteBucket(BObject clientObj, BString bucket) {
        S3Client s3 = getClient(clientObj);
        try {
            s3.deleteBucket(DeleteBucketRequest.builder().bucket(bucket.getValue()).build());
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    @SuppressWarnings("unchecked")
    public static Object listBuckets(BObject clientObj) {
        S3Client s3 = getClient(clientObj);
        try {
            List<Bucket> buckets = s3.listBuckets().buckets();
            MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
            BMap<BString, Object>[] bBuckets = new BMap[buckets.size()];

            for (int i = 0; i < buckets.size(); i++) {
                Bucket bucket = buckets.get(i);
                BMap<BString, Object> bucketRecord = ValueCreator.createMapValue(mapType);

                // Set bucket name
                bucketRecord.put(StringUtils.fromString("name"), StringUtils.fromString(bucket.name()));

                // Set creation date
                Instant creationDate = bucket.creationDate();
                String creationDateStr = creationDate != null ? creationDate.toString() : "";
                bucketRecord.put(StringUtils.fromString("creationDate"), StringUtils.fromString(creationDateStr));

                // Get bucket region
                String region = "";
                try {
                    GetBucketLocationRequest locationRequest = GetBucketLocationRequest.builder()
                            .bucket(bucket.name())
                            .build();
                    GetBucketLocationResponse locationResponse = s3.getBucketLocation(locationRequest);
                    region = locationResponse.locationConstraintAsString();
                    if (region == null || region.isEmpty()) {
                        region = "us-east-1";
                    }
                } catch (Exception e) {
                    region = "";
                }
                bucketRecord.put(StringUtils.fromString("region"), StringUtils.fromString(region));

                bBuckets[i] = bucketRecord;
            }
            return ValueCreator.createArrayValue(bBuckets,
                    TypeCreator.createArrayType(PredefinedTypes.TYPE_JSON));
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object getBucketLocation(BObject clientObj, BString bucket) {
        S3Client s3 = getClient(clientObj);
        try {
            GetBucketLocationRequest request = GetBucketLocationRequest.builder()
                    .bucket(bucket.getValue())
                    .build();
            GetBucketLocationResponse response = s3.getBucketLocation(request);
            String location = response.locationConstraintAsString();
            return StringUtils.fromString(location != null ? location : "us-east-1");
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    // Object Operations

    public static Object putObjectFromFile(BObject clientObj, BString bucket, BString key, BString filePath,
            BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
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
        S3Client s3 = getClient(clientObj);
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
        S3Client s3 = getClient(clientObj);

        try {
            long contentLength = config.getIntValue(StringUtils.fromString("contentLength"));

            // Validate contentLength is positive
            if (contentLength <= 0) {
                return ErrorCreator.createError(
                        "contentLength must be a positive value, got: " + contentLength);
            }

            // Create input stream from Ballerina stream
            InputStream inputStream = new BallerinaStreamInputStream(env, contentStream);

            PutObjectRequest.Builder builder = PutObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .contentLength(contentLength);

            applyPutObjectConfig(builder, config);

            s3.putObject(builder.build(), RequestBody.fromInputStream(inputStream, contentLength));

            // Close the stream
            inputStream.close();

            return null;

        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    private static void applyPutObjectConfig(PutObjectRequest.Builder builder, BMap<BString, Object> config) {
        applyStringConfig(config, "contentType", builder::contentType);
        applyStringConfig(config, "acl", builder::acl);
        applyStringConfig(config, "storageClass", builder::storageClass);
        applyStringConfig(config, "cacheControl", builder::cacheControl);
        applyStringConfig(config, "contentDisposition", builder::contentDisposition);
        applyStringConfig(config, "contentEncoding", builder::contentEncoding);
        applyStringConfig(config, "contentLanguage", builder::contentLanguage);
        applyStringConfig(config, "tagging", builder::tagging);
        applyStringConfig(config, "serverSideEncryption", builder::serverSideEncryption);
        applyMetadataConfig(config, "metadata", builder::metadata);
    }

    public static Object getObject(Environment env, BObject clientObj, BString bucket, BString key,
            BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        try {
            GetObjectRequest.Builder builder = GetObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, "versionId", builder::versionId);
            applyStringConfig(config, "range", builder::range);
            applyStringConfig(config, "ifMatch", builder::ifMatch);
            applyStringConfig(config, "ifNoneMatch", builder::ifNoneMatch);
            applyInstantConfig(config, "ifModifiedSince", builder::ifModifiedSince);
            applyInstantConfig(config, "ifUnmodifiedSince", builder::ifUnmodifiedSince);
            applyIntConfig(config, "partNumber", builder::partNumber);

            ResponseInputStream<GetObjectResponse> s3Stream = s3.getObject(builder.build());
            BObject streamWrapper = ValueCreator.createObjectValue(env.getCurrentModule(), "StreamIterator");
            streamWrapper.addNativeData("NATIVE_STREAM", s3Stream);
            return streamWrapper;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object getObjectWithType(Environment env, BObject clientObj, BString bucket, BString key,
            BTypedesc targetType, BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        try {
            GetObjectRequest.Builder builder = GetObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, "versionId", builder::versionId);
            applyStringConfig(config, "range", builder::range);
            applyStringConfig(config, "ifMatch", builder::ifMatch);
            applyStringConfig(config, "ifNoneMatch", builder::ifNoneMatch);
            applyInstantConfig(config, "ifModifiedSince", builder::ifModifiedSince);
            applyInstantConfig(config, "ifUnmodifiedSince", builder::ifUnmodifiedSince);
            applyIntConfig(config, "partNumber", builder::partNumber);

            ResponseBytes<GetObjectResponse> responseBytes = s3.getObjectAsBytes(builder.build());
            byte[] bytes = responseBytes.asByteArray();
            BArray byteArray = ValueCreator.createArrayValue(bytes);

            // Call Ballerina getObjectInternal method to do the conversion
            return env.getRuntime().callMethod(
                    clientObj,
                    "getObjectInternal",
                    null,
                    byteArray,
                    targetType);
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object deleteObject(BObject clientObj, BString bucket, BString key, BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        try {
            DeleteObjectRequest.Builder builder = DeleteObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, "versionId", builder::versionId);
            applyStringConfig(config, "mfa", builder::mfa);
            applyBooleanConfig(config, "bypassGovernanceRetention", builder::bypassGovernanceRetention);

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
        S3Client s3 = getClient(clientObj);
        try {
            ListObjectsV2Request.Builder builder = ListObjectsV2Request.builder()
                    .bucket(bucket.getValue());

            applyStringConfig(config, "prefix", builder::prefix);
            applyStringConfig(config, "delimiter", builder::delimiter);
            applyIntConfig(config, "maxKeys", builder::maxKeys);
            applyStringConfig(config, "continuationToken", builder::continuationToken);
            applyStringConfig(config, "startAfter", builder::startAfter);
            applyBooleanConfig(config, "fetchOwner", builder::fetchOwner);

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

                objMap.put(StringUtils.fromString("key"), StringUtils.fromString(obj.key()));
                objMap.put(StringUtils.fromString("size"), (long) obj.size());
                objMap.put(StringUtils.fromString("lastModified"),
                        StringUtils.fromString(obj.lastModified().toString()));
                objMap.put(StringUtils.fromString("eTag"), StringUtils.fromString(obj.eTag()));
                objMap.put(StringUtils.fromString("storageClass"), StringUtils.fromString(obj.storageClassAsString()));

                objArray[i] = objMap;
            }

            // Convert array to BArray using ValueCreator
            BArray objectsArray = ValueCreator.createArrayValue(objArray,
                    TypeCreator.createArrayType(PredefinedTypes.TYPE_JSON));

            result.put(StringUtils.fromString("objects"), objectsArray);
            result.put(StringUtils.fromString("count"), (long) size);
            result.put(StringUtils.fromString("isTruncated"), response.isTruncated());

            if (response.nextContinuationToken() != null) {
                result.put(StringUtils.fromString("nextContinuationToken"),
                        StringUtils.fromString(response.nextContinuationToken()));
            }

            return result;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object headObject(BObject clientObj, BString bucket, BString key, BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        try {
            HeadObjectRequest.Builder builder = HeadObjectRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue());

            applyStringConfig(config, "versionId", builder::versionId);
            applyIntConfig(config, "partNumber", builder::partNumber);

            HeadObjectResponse response = s3.headObject(builder.build());
            MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
            BMap<BString, Object> metadata = ValueCreator.createMapValue(mapType);

            metadata.put(StringUtils.fromString("key"), key);
            metadata.put(StringUtils.fromString("contentLength"), response.contentLength());
            if (response.contentType() != null) {
                metadata.put(StringUtils.fromString("contentType"), StringUtils.fromString(response.contentType()));
            }
            metadata.put(StringUtils.fromString("eTag"), StringUtils.fromString(response.eTag()));
            metadata.put(StringUtils.fromString("lastModified"),
                    StringUtils.fromString(response.lastModified().toString()));
            String storageClass = response.storageClassAsString();
            metadata.put(StringUtils.fromString("storageClass"),
                    StringUtils.fromString(storageClass != null ? storageClass : "STANDARD"));
            if (response.versionId() != null) {
                metadata.put(StringUtils.fromString("versionId"), StringUtils.fromString(response.versionId()));
            }

            if (response.metadata() != null && !response.metadata().isEmpty()) {
                BMap<BString, Object> userMeta = ValueCreator.createMapValue(mapType);
                response.metadata()
                        .forEach((k, v) -> userMeta.put(StringUtils.fromString(k), StringUtils.fromString(v)));
                metadata.put(StringUtils.fromString("userMetadata"), userMeta);
            }

            return metadata;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object copyObject(BObject clientObj, BString sourceBucket, BString sourceKey, BString destBucket,
            BString destKey, BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        try {
            CopyObjectRequest.Builder builder = CopyObjectRequest.builder()
                    .sourceBucket(sourceBucket.getValue())
                    .sourceKey(sourceKey.getValue())
                    .destinationBucket(destBucket.getValue())
                    .destinationKey(destKey.getValue());

            applyStringConfig(config, "acl", builder::acl);
            applyStringConfig(config, "storageClass", builder::storageClass);
            applyStringConfig(config, "metadataDirective", builder::metadataDirective);
            applyStringConfig(config, "contentType", builder::contentType);
            applyMetadataConfig(config, "metadata", builder::metadata);

            s3.copyObject(builder.build());
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static boolean doesObjectExist(BObject clientObj, BString bucket, BString key) {
        S3Client s3 = getClient(clientObj);
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
            throw ErrorCreator.createError(e);
        }
    }

    // Multipart Upload Operations

    public static Object createMultipartUpload(BObject clientObj, BString bucket, BString key,
            BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
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
        applyStringConfig(config, "contentType", builder::contentType);
        applyStringConfig(config, "acl", builder::acl);
        applyStringConfig(config, "storageClass", builder::storageClass);
        applyStringConfig(config, "tagging", builder::tagging);
        applyStringConfig(config, "serverSideEncryption", builder::serverSideEncryption);
        applyMetadataConfig(config, "metadata", builder::metadata);
    }

    public static Object uploadPart(BObject clientObj, BString bucket, BString key, BString uploadId,
            long partNumber, BArray content, BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        try {
            byte[] contentBytes = content.getBytes();

            UploadPartRequest.Builder builder = UploadPartRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .uploadId(uploadId.getValue())
                    .partNumber((int) partNumber);

            applyLongConfig(config, "contentLength", builder::contentLength);
            applyStringConfig(config, "contentMD5", builder::contentMD5);

            UploadPartRequest request = builder.build();
            UploadPartResponse response = s3.uploadPart(request, RequestBody.fromBytes(contentBytes));

            return StringUtils.fromString(response.eTag());
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object uploadPartWithStream(Environment env, BObject clientObj, BString bucket, BString key,
            BString uploadId, long partNumber, BStream contentStream, BMap<BString, Object> config) {
        S3Client s3 = getClient(clientObj);
        try {
            long contentLength = config.getIntValue(StringUtils.fromString("contentLength"));

            UploadPartRequest.Builder builder = UploadPartRequest.builder()
                    .bucket(bucket.getValue())
                    .key(key.getValue())
                    .uploadId(uploadId.getValue())
                    .partNumber((int) partNumber)
                    .contentLength(contentLength);

            applyStringConfig(config, "contentMD5", builder::contentMD5);

            InputStream inputStream = new BallerinaStreamInputStream(env, contentStream);

            UploadPartResponse response = s3.uploadPart(builder.build(),
                    RequestBody.fromInputStream(inputStream, contentLength));

            inputStream.close();

            return StringUtils.fromString(response.eTag());
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object completeMultipartUpload(BObject clientObj, BString bucket, BString key, BString uploadId,
            BArray partNumbers, BArray etags) {
        S3Client s3 = getClient(clientObj);
        try {
            List<CompletedPart> parts = new ArrayList<>();
            long[] pNums = partNumbers.getIntArray();
            String[] eTagsStr = etags.getStringArray();

            for (int i = 0; i < pNums.length; i++) {
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
        S3Client s3 = getClient(clientObj);
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
            long expirationMinutes = config.getIntValue(StringUtils.fromString("expirationMinutes"));

            Object methodObj = config.get(StringUtils.fromString("httpMethod"));
            String httpMethod = (methodObj instanceof BString)
                    ? ((BString) methodObj).getValue().toUpperCase()
                    : "GET";

            ConnectionConfig connConfig = getConnectionConfig(clientObj);

            presigner = S3Presigner.builder()
                    .region(connConfig.region)
                    .credentialsProvider(connConfig.credentialsProvider)
                    .build();

            String presignedUrl = "GET".equals(httpMethod)
                    ? generateGetPresignedUrl(presigner, bucket.getValue(), key.getValue(), expirationMinutes, config)
                    : "PUT".equals(httpMethod)
                            ? generatePutPresignedUrl(presigner, bucket.getValue(), key.getValue(), expirationMinutes,
                                    config)
                            : null;

            if (presignedUrl == null) {
                return ErrorCreator.createError(
                        "Unsupported HTTP method: " + httpMethod + ". Supported methods: GET, PUT");
            }

            return StringUtils.fromString(presignedUrl);

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

        applyStringConfig(config, "versionId", getBuilder::versionId);
        applyStringConfig(config, "responseContentType", getBuilder::responseContentType);
        applyStringConfig(config, "contentDisposition", getBuilder::responseContentDisposition);

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

        applyStringConfig(config, "contentType", putBuilder::contentType);
        applyStringConfig(config, "contentDisposition", putBuilder::contentDisposition);

        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(Duration.ofMinutes(expirationMinutes))
                .putObjectRequest(putBuilder.build())
                .build();

        PresignedPutObjectRequest presignedRequest = presigner.presignPutObject(presignRequest);
        return presignedRequest.url().toString();
    }
}
