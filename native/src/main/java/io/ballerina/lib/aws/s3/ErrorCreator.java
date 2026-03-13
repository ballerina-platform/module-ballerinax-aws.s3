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
import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import software.amazon.awssdk.services.s3.model.S3Exception;

/**
 * Utility class for creating Ballerina errors from the aws.s3 module.
 */
public class ErrorCreator {

    private static Module s3Module;

    // Error type names matching Ballerina error definitions
    private static final String ERROR = "Error";
    private static final String NO_SUCH_KEY_ERROR = "NoSuchKeyError";
    private static final String BUCKET_ALREADY_EXISTS_ERROR = "BucketAlreadyExistsError";
    private static final String BUCKET_ALREADY_OWNED_BY_YOU_ERROR = "BucketAlreadyOwnedByYouError";
    private static final String NO_SUCH_BUCKET_ERROR = "NoSuchBucketError";
    private static final String BUCKET_NOT_EMPTY_ERROR = "BucketNotEmptyError";

    /**
     * Initialize the module reference. Should be called during client initialization.
     */
    public static void initModule(Environment env) {
        // Prefer module stored in ModuleUtils (set during Ballerina module init). Fall back to env.
        Module moduleFromUtils = ModuleUtils.getModule();
        if (moduleFromUtils != null) {
            s3Module = moduleFromUtils;
        } else {
            s3Module = env.getCurrentModule();
        }
    }

    /**
     * Creates a Ballerina Error of type `ballerinax/aws.s3:Error`.
     *
     * @param message The error message
     * @return BError instance of module's Error type
     */
    public static BError createError(String message) {
        return createError(ERROR, message);
    }

    /**
     * Creates a Ballerina Error of the specified type.
     *
     * @param errorType The error type name
     * @param message   The error message
     * @return BError instance of the specified type
     */
    public static BError createError(String errorType, String message) {
        if (s3Module != null) {
            return io.ballerina.runtime.api.creators.ErrorCreator.createError(s3Module, errorType,
                StringUtils.fromString(message), null, null);
        }
        return io.ballerina.runtime.api.creators.ErrorCreator.createError(StringUtils.fromString(message));
    }

    /**
     * Creates a Ballerina Error of type `ballerinax/aws.s3:Error` with a cause.
     *
     * @param message The error message
     * @param cause   The cause error
     * @return BError instance of module's Error type
     */
    public static BError createError(String message, BError cause) {
        if (s3Module != null) {
            return io.ballerina.runtime.api.creators.ErrorCreator.createError(s3Module, ERROR,
                StringUtils.fromString(message), cause, null);
        }
        return io.ballerina.runtime.api.creators.ErrorCreator.createError(StringUtils.fromString(message), cause);
    }

    /**
     * Creates a Ballerina Error from a Throwable.
     * Maps AWS S3 specific exceptions to corresponding Ballerina sub-error types.
     *
     * @param t The throwable
     * @return BError instance of the appropriate error type
     */
    public static BError createError(Throwable t) {
        if (t instanceof S3Exception) {
            S3Exception s3Ex = (S3Exception) t;
            String errorCode = s3Ex.awsErrorDetails() != null ?
                    s3Ex.awsErrorDetails().errorCode() : null;
            String errorMessage = s3Ex.awsErrorDetails() != null ?
                    s3Ex.awsErrorDetails().errorMessage() : s3Ex.getMessage();
            String message = errorMessage != null ? errorMessage : s3Ex.getMessage();

            // Map AWS error codes to Ballerina error types
            String errorType = mapErrorCode(errorCode);
            return createError(errorType, message);
        }
        String message = t.getMessage() != null ? t.getMessage() : t.getClass().getSimpleName();
        return createError(message);
    }

    /**
     * Maps AWS S3 error codes to Ballerina error type names.
     *
     * @param errorCode The AWS error code
     * @return The corresponding Ballerina error type name
     */
    private static String mapErrorCode(String errorCode) {
        if (errorCode == null) {
            return ERROR;
        }
        switch (errorCode) {
            case "NoSuchKey":
                return NO_SUCH_KEY_ERROR;
            case "BucketAlreadyExists":
                return BUCKET_ALREADY_EXISTS_ERROR;
            case "BucketAlreadyOwnedByYou":
                return BUCKET_ALREADY_OWNED_BY_YOU_ERROR;
            case "NoSuchBucket":
                return NO_SUCH_BUCKET_ERROR;
            case "BucketNotEmpty":
                return BUCKET_NOT_EMPTY_ERROR;
            default:
                return ERROR;
        }
    }
}
