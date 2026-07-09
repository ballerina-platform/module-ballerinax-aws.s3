// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
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
import io.ballerina.runtime.api.concurrent.StrandMetadata;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Response;
import software.amazon.awssdk.services.s3.model.NoSuchBucketException;
import software.amazon.awssdk.services.s3.model.S3Object;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Native implementation of the S3 Listener.
 */
public class ListenerActions {
    private static final Logger LOGGER = Logger.getLogger(ListenerActions.class.getName());

    private static final String NATIVE_S3_CLIENT = "NATIVE_LISTENER_S3_CLIENT";
    private static final String NATIVE_BUCKET_NAME = "NATIVE_BUCKET_NAME";
    private static final String NATIVE_PREFIX = "NATIVE_PREFIX";
    private static final String NATIVE_KNOWN_OBJECTS = "NATIVE_KNOWN_OBJECTS";

    private static final String ON_CREATE = "onCreate";
    private static final String ON_MODIFY = "onUpdate";
    private static final String ON_DELETE = "onDelete";
    private static final String ON_ERROR = "onError";
    private static final StrandMetadata DISPATCH_METADATA = new StrandMetadata(false, null);

    private static final BString BUCKET_NAME_FIELD = StringUtils.fromString("bucketName");
    private static final BString OBJECT_FIELD = StringUtils.fromString("object");
    private static final BString OBJECT_KEY_FIELD = StringUtils.fromString("objectKey");
    private static final BString PREVIOUS_ETAG_FIELD = StringUtils.fromString("previousETag");

    private ListenerActions() {}

    public static Object init(BObject listenerObj, BString bucketName, BMap<BString, Object> config) {
        try {
            Object authObj = config.get(NativeClientAdaptor.AUTH);
            if (!(authObj instanceof BMap) && !(authObj instanceof BString)) {
                return ErrorCreator.createError("Invalid auth configuration provided");
            }

            String region = config.getStringValue(NativeClientAdaptor.REGION).getValue();
            S3Client s3Client = NativeClientAdaptor.buildS3Client(authObj, region);

            Object prefixObj = config.get(StringUtils.fromString("prefix"));
            String prefix = (prefixObj instanceof BString bPrefix) ? bPrefix.getValue() : null;

            listenerObj.addNativeData(NATIVE_S3_CLIENT, s3Client);
            listenerObj.addNativeData(NATIVE_BUCKET_NAME, bucketName.getValue());
            listenerObj.addNativeData(NATIVE_PREFIX, prefix);
            listenerObj.addNativeData(NATIVE_KNOWN_OBJECTS, new HashMap<String, String>());
            return null;
        } catch (Exception e) {
            return ErrorCreator.createError(e);
        }
    }

    public static Object poll(Environment env, BObject listenerObj, BObject service) {
        S3Client s3 = (S3Client) listenerObj.getNativeData(NATIVE_S3_CLIENT);
        String bucketName = (String) listenerObj.getNativeData(NATIVE_BUCKET_NAME);
        String prefix = (String) listenerObj.getNativeData(NATIVE_PREFIX);
        Map<String, String> knownObjects = (Map<String, String>) listenerObj.getNativeData(NATIVE_KNOWN_OBJECTS);

        try {
            Map<String, String> current = new HashMap<>();
            Map<String, S3Object> currentObjects = new LinkedHashMap<>();
            String continuationToken = null;
            boolean isTruncated = true;

            while (isTruncated) {
                ListObjectsV2Request.Builder req = ListObjectsV2Request.builder()
                        .bucket(bucketName)
                        .maxKeys(1000);
                if (prefix != null) {
                    req.prefix(prefix);
                }
                if (continuationToken != null) {
                    req.continuationToken(continuationToken);
                }
                ListObjectsV2Response response = s3.listObjectsV2(req.build());
                for (S3Object obj : response.contents()) {
                    current.put(obj.key(), obj.eTag() != null ? obj.eTag() : "");
                    currentObjects.put(obj.key(), obj);
                }
                isTruncated = Boolean.TRUE.equals(response.isTruncated());
                continuationToken = response.nextContinuationToken();
            }
            for (Map.Entry<String, S3Object> entry : currentObjects.entrySet()) {
                String key = entry.getKey();
                S3Object obj = entry.getValue();
                if (!knownObjects.containsKey(key)) {
                    dispatch(env, service, ON_CREATE, createCreatedEvent(bucketName, obj), key);
                } else if (!knownObjects.get(key).equals(current.get(key))) {
                    dispatch(env, service, ON_MODIFY,
                            createModifiedEvent(bucketName, obj, knownObjects.get(key)), key);
                }
            }
            for (String key : knownObjects.keySet()) {
                if (!current.containsKey(key)) {
                    dispatch(env, service, ON_DELETE, createDeletedEvent(bucketName, key), key);
                }
            }
            knownObjects.clear();
            knownObjects.putAll(current);
        } catch (NoSuchBucketException e) {
            BError bError = ErrorCreator.createError(e);
            dispatchError(env, service, bError);
            return bError;
        } catch (Exception e) {
            dispatchError(env, service, ErrorCreator.createError(e));
        }
        return null;
    }

    private static void dispatch(Environment env, BObject service, String method,
            BMap<BString, Object> event, String key) {
        Object result = env.getRuntime().callMethod(service, method, DISPATCH_METADATA, event);
        if (result instanceof BError error) {
            dispatchError(env, service, error);
        }
    }

    private static void dispatchError(Environment env, BObject service, BError error) {
        Object result = env.getRuntime().callMethod(service, ON_ERROR, DISPATCH_METADATA, error);
        if (result instanceof BError handlerError) {
            LOGGER.warning("Error in onError handler: " + handlerError.getMessage());
        }
    }

    private static BMap<BString, Object> buildS3ObjectRecord(S3Object obj) {
        @SuppressWarnings("unchecked")
        BMap<BString, Object> record = ValueCreator.createRecordValue(ModuleUtils.getModule(), "S3Object");
        record.put(NativeClientAdaptor.KEY, StringUtils.fromString(obj.key()));
        record.put(NativeClientAdaptor.SIZE, obj.size() != null ? obj.size() : 0L);
        record.put(NativeClientAdaptor.LAST_MODIFIED,
                StringUtils.fromString(obj.lastModified() != null ? obj.lastModified().toString() : ""));
        record.put(NativeClientAdaptor.E_TAG,
                StringUtils.fromString(obj.eTag() != null ? obj.eTag() : ""));
        record.put(StringUtils.fromString(NativeClientAdaptor.STORAGE_CLASS),
                StringUtils.fromString(obj.storageClassAsString() != null
                        ? obj.storageClassAsString() : NativeClientAdaptor.STANDARD));
        return record;
    }

    private static BMap<BString, Object> createCreatedEvent(String bucketName, S3Object obj) {
        @SuppressWarnings("unchecked")
        BMap<BString, Object> event =
                ValueCreator.createRecordValue(ModuleUtils.getModule(), "CreatedEvent");
        event.put(BUCKET_NAME_FIELD, StringUtils.fromString(bucketName));
        event.put(OBJECT_FIELD, buildS3ObjectRecord(obj));
        return event;
    }

    private static BMap<BString, Object> createModifiedEvent(String bucketName, S3Object obj, String previousETag) {
        @SuppressWarnings("unchecked")
        BMap<BString, Object> event =
                ValueCreator.createRecordValue(ModuleUtils.getModule(), "UpdatedEvent");
        event.put(BUCKET_NAME_FIELD, StringUtils.fromString(bucketName));
        event.put(OBJECT_FIELD, buildS3ObjectRecord(obj));
        event.put(PREVIOUS_ETAG_FIELD, StringUtils.fromString(previousETag));
        return event;
    }

    private static BMap<BString, Object> createDeletedEvent(String bucketName, String objectKey) {
        @SuppressWarnings("unchecked")
        BMap<BString, Object> event =
                ValueCreator.createRecordValue(ModuleUtils.getModule(), "DeletedEvent");
        event.put(BUCKET_NAME_FIELD, StringUtils.fromString(bucketName));
        event.put(OBJECT_KEY_FIELD, StringUtils.fromString(objectKey));
        return event;
    }
}
