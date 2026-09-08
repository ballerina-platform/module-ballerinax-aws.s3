/*
 * Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com)
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.aws.s3.observability;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.observability.ObservabilityConstants;
import io.ballerina.runtime.observability.ObserveUtils;
import io.ballerina.runtime.observability.ObserverContext;
import io.ballerina.runtime.observability.tracer.BSpan;

/**
 * Utility class for injecting S3 observability context into Ballerina strands and spans.
 *
 * <p>For client operations, call {@link #sendMetricsData} from inside a native external
 * method. Ballerina has already created an auto-instrumented span for the remote-method call;
 * this helper enriches that span with the S3-specific tags ({@code action.type},
 * {@code type}, {@code remote.url}, etc.) so that the resulting
 * {@code requests_total_value} metric is correctly labelled.
 */
public class S3TracingUtil {

    private S3TracingUtil() {
    }

    /**
     * Enriches the auto-instrumented span for the currently executing native external method with
     * S3 client-operation tags. Metric tags ({@code action.type}, {@code type},
     * {@code remote.url}, {@code protocol}, {@code operation.type}) are added to the
     * {@link ObserverContext}; {@code file.path} and {@code destination.path} are span-only and
     * excluded from metrics to prevent unbounded label cardinality.
     *
     * @param env           the current Ballerina environment
     * @param url           remote URL
     * @param protocol      protocol string
     * @param operationType one of the {@code S3MetricsUtil.OPERATION_TYPE_*} constants
     * @param objectKey     S3 object key (added as span-only tag)
     */
    public static void sendMetricsData(Environment env, String url, String protocol,
                                       String operationType, String objectKey) {
        sendMetricsData(env, url, protocol, operationType, objectKey, null);
    }

    /**
     * Variant for two-path operations (e.g., copy), adding a span-only {@code destination.path} tag.
     *
     * @param env            the current Ballerina environment
     * @param url            remote URL
     * @param protocol       protocol string
     * @param operationType  operation type constant
     * @param objectKey      source object key
     * @param destinationKey destination object key, or {@code null}
     */
    public static void sendMetricsData(Environment env, String url, String protocol,
                                       String operationType, String objectKey,
                                       String destinationKey) {
        try {
            ObserverContext ctx = ObserveUtils.getObserverContextOfCurrentFrame(env);
            if (ctx == null) {
                return;
            }
            ctx.addTag(S3ObserverContext.TAG_MODULE, S3MetricsUtil.MODULE_S3);
            ctx.addTag(S3ObserverContext.TAG_ACTION_TYPE, S3MetricsUtil.ACTION_TYPE_OPERATION);
            ctx.addTag(S3ObserverContext.TAG_CONTEXT, S3MetricsUtil.CONTEXT_CLIENT);
            ctx.addTag(S3ObserverContext.TAG_REMOTE_URL, url);
            ctx.addTag(S3ObserverContext.TAG_PROTOCOL, protocol);
            ctx.addTag(S3ObserverContext.TAG_OPERATION_TYPE, operationType);
            String instanceUrl = S3MetricsUtil.getInstanceUrl();
            if (instanceUrl != null) {
                ctx.addTag(S3ObserverContext.TAG_INSTANCE_URL, instanceUrl);
            }
            BSpan span = ctx.getSpan();
            if (span != null) {
                if (objectKey != null) {
                    span.addTag(S3ObserverContext.TAG_FILE_PATH, objectKey);
                }
                if (destinationKey != null) {
                    span.addTag(S3ObserverContext.TAG_DESTINATION_PATH, destinationKey);
                }
            }
        } catch (Throwable t) {
            // Observability failures must not break S3 operations
        }
    }

    /**
     * Tags the auto-instrumented span with a successful outcome.
     *
     * @param env the current Ballerina environment
     */
    public static void reportSuccess(Environment env) {
        try {
            ObserverContext ctx = ObserveUtils.getObserverContextOfCurrentFrame(env);
            if (ctx != null) {
                ctx.addTag(S3ObserverContext.TAG_OUTCOME, S3MetricsUtil.OUTCOME_SUCCESS);
            }
        } catch (Throwable t) {
            // Observability failures must not break S3 operations
        }
    }

    /**
     * Adds {@code error=true} and {@code error.type} tags to the auto-instrumented span for the
     * currently executing native external method. Call this after an operation returns a
     * {@link io.ballerina.runtime.api.values.BError} to record the error on the span.
     *
     * @param env       the current Ballerina environment
     * @param errorType Ballerina error type name (e.g. {@code "Error"})
     */
    public static void sendErrorMetricsOnCurrentFrame(Environment env, String errorType) {
        try {
            ObserverContext ctx = ObserveUtils.getObserverContextOfCurrentFrame(env);
            if (ctx == null) {
                return;
            }
            ctx.addTag(ObservabilityConstants.TAG_KEY_ERROR, ObservabilityConstants.TAG_TRUE_VALUE);
            ctx.addTag(S3ObserverContext.TAG_ERROR_TYPE, errorType);
            ctx.addTag(S3ObserverContext.TAG_OUTCOME, S3MetricsUtil.OUTCOME_FAILURE);
        } catch (Throwable t) {
            // Observability failures must not break S3 operations
        }
    }
}
