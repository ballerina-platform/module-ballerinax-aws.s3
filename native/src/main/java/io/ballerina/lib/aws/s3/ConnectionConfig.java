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

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.regions.Region;

/**
 * Holds the AWS S3 connection configuration including region, credentials provider, and endpoint configuration.
 */
public class ConnectionConfig {
    public final Region region;
    public final AwsCredentialsProvider credentialsProvider;
    public final BMap<BString, Object> endpointConfig;

    public ConnectionConfig(Region region, AwsCredentialsProvider credentialsProvider,
                            BMap<BString, Object> endpointConfig) {
        this.region = region;
        this.credentialsProvider = credentialsProvider;
        this.endpointConfig = endpointConfig;
    }
}
