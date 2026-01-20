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

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BObject;

import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;

import java.io.IOException;

public class StreamIteratorUtils {

    // Stream Operations
    @SuppressWarnings("unchecked")
    public static Object readStreamBytes(BObject streamWrapper) {
        ResponseInputStream<GetObjectResponse> input = (ResponseInputStream<GetObjectResponse>) streamWrapper
                .getNativeData("NATIVE_STREAM");
        if (input == null)
            return ErrorCreator.createError("Stream is closed.");

        try {
            byte[] buffer = new byte[4096];
            int read = input.read(buffer);
            if (read == -1) {
                input.close();
                streamWrapper.addNativeData("NATIVE_STREAM", null);
                return null;
            }
            if (read < 4096) {
                byte[] trimmed = new byte[read];
                System.arraycopy(buffer, 0, trimmed, 0, read);
                return ValueCreator.createArrayValue(trimmed);
            }
            return ValueCreator.createArrayValue(buffer);
        } catch (IOException e) {
            return ErrorCreator.createError(e);
        }
    }

    @SuppressWarnings("unchecked")
    public static Object closeStream(BObject streamWrapper) {
        ResponseInputStream<GetObjectResponse> input = (ResponseInputStream<GetObjectResponse>) streamWrapper
                .getNativeData("NATIVE_STREAM");
        if (input == null) {
            return null; // Already closed
        }

        try {
            input.close();
            streamWrapper.addNativeData("NATIVE_STREAM", null);
            return null;
        } catch (IOException e) {
            return ErrorCreator.createError(e);
        }
    }
}
