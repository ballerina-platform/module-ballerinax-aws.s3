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

import io.ballerina.runtime.observability.ObserveUtils;
import io.ballerina.runtime.observability.metrics.DefaultMetricRegistry;
import io.ballerina.runtime.observability.metrics.MetricId;
import io.ballerina.runtime.observability.metrics.MetricRegistry;

import java.net.InetAddress;

/**
 * Utility class for recording AWS S3 connector metrics.
 *
 * <p>All public methods swallow exceptions internally so that observability failures
 * never break S3 operations.
 *
 * <p>Metrics published:
 * <ul>
 *   <li>{@code s3_active_connections} (gauge) — number of active S3 client connections</li>
 *   <li>{@code file_bytes_transferred_total} (counter) — total bytes read or written</li>
 * </ul>
 */
public class S3MetricsUtil {

    private static final String CONNECTOR_NAME = "s3";
    private static final String FILE_CONNECTOR_NAME = "file";
    private static final String[] METRIC_ACTIVE_CONNECTIONS = {
            "active_connections", "Number of active S3 connections"};
    private static final String[] METRIC_BYTES_TRANSFERRED = {
            "bytes_transferred_total", "Total bytes read or written across operations"};

    /** Sentinel used when a URL or protocol value is unavailable. */
    public static final String UNKNOWN = "unknown";

    /** Sentinel used when a tag is not applicable, ensuring consistent label sets. */
    public static final String NONE = "none";

    /** Module tag value identifying the S3 module. */
    public static final String MODULE_S3 = "s3";

    /** Context tag value for S3 client operations. */
    public static final String CONTEXT_CLIENT = "client";

    /** Default protocol for S3 connections. */
    public static final String PROTOCOL_HTTPS = "https";

    /** Operation-type tag value: read object content. */
    public static final String OPERATION_TYPE_GET = "get";

    /** Operation-type tag value: write object content. */
    public static final String OPERATION_TYPE_PUT = "put";

    /** Operation-type tag value: admin/management operations. */
    public static final String OPERATION_TYPE_MANAGE = "manage";

    /** Action-type tag value for S3 client operations. */
    public static final String ACTION_TYPE_OPERATION = "client_operation";

    /** Outcome: operation succeeded. */
    public static final String OUTCOME_SUCCESS = "success";

    /** Outcome: operation failed. */
    public static final String OUTCOME_FAILURE = "failure";

    private static final MetricRegistry metricRegistry = DefaultMetricRegistry.getInstance();

    private static String instanceUrl;
    private static boolean instanceUrlResolved;

    private S3MetricsUtil() {
    }

    /** Returns the hostname of the current instance, resolved lazily on first use, or {@code null} if unavailable. */
    public static String getInstanceUrl() {
        if (!instanceUrlResolved) {
            try {
                instanceUrl = InetAddress.getLocalHost().getHostName();
            } catch (Exception e) {
                instanceUrl = null;
            }
            instanceUrlResolved = true;
        }
        return instanceUrl;
    }

    /**
     * Increments the {@code s3_active_connections} gauge when a new S3 client is created.
     *
     * @param url      remote URL of the S3 endpoint
     * @param protocol "https" or "http"
     */
    public static void reportNewConnection(String url, String protocol) {
        if (!ObserveUtils.isMetricsEnabled()) {
            return;
        }
        try {
            S3ObserverContext observerContext = new S3ObserverContext(CONTEXT_CLIENT, url, protocol);
            metricRegistry.gauge(new MetricId(CONNECTOR_NAME + "_" + METRIC_ACTIVE_CONNECTIONS[0],
                    METRIC_ACTIVE_CONNECTIONS[1], observerContext.getAllTags())).increment();
        } catch (Throwable t) {
            // Observability failures must not break S3 operations
        }
    }

    /**
     * Decrements the {@code s3_active_connections} gauge when an S3 client is closed.
     *
     * @param url      remote URL of the S3 endpoint
     * @param protocol "https" or "http"
     */
    public static void reportConnectionClose(String url, String protocol) {
        if (!ObserveUtils.isMetricsEnabled()) {
            return;
        }
        try {
            S3ObserverContext observerContext = new S3ObserverContext(CONTEXT_CLIENT, url, protocol);
            metricRegistry.gauge(new MetricId(CONNECTOR_NAME + "_" + METRIC_ACTIVE_CONNECTIONS[0],
                    METRIC_ACTIVE_CONNECTIONS[1], observerContext.getAllTags())).decrement();
        } catch (Throwable t) {
            // Observability failures must not break S3 operations
        }
    }

    /**
     * Reports bytes transferred during a file operation (get or put).
     *
     * @param url           remote URL of the S3 endpoint
     * @param protocol      "https" or "http"
     * @param operationType {@link #OPERATION_TYPE_GET} or {@link #OPERATION_TYPE_PUT}
     * @param bytes         number of bytes transferred
     */
    public static void reportBytesTransferred(String url, String protocol, String operationType, long bytes) {
        if (!ObserveUtils.isMetricsEnabled() || bytes <= 0) {
            return;
        }
        try {
            S3ObserverContext observerContext = new S3ObserverContext(CONTEXT_CLIENT, url, protocol);
            observerContext.addTag(S3ObserverContext.TAG_OPERATION_TYPE, operationType);
            metricRegistry.counter(new MetricId(FILE_CONNECTOR_NAME + "_" + METRIC_BYTES_TRANSFERRED[0],
                    METRIC_BYTES_TRANSFERRED[1], observerContext.getAllTags())).increment(bytes);
        } catch (Throwable t) {
            // Observability failures must not break S3 operations
        }
    }
}
