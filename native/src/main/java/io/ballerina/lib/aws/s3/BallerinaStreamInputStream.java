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
import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BStream;

import java.io.IOException;
import java.io.InputStream;

/**
 * Helper class to convert Ballerina stream to Java InputStream.
 * This enables reading data from a Ballerina byte stream in Java code.
 */
public class BallerinaStreamInputStream extends InputStream {
    private static final String BAL_STREAM_CLOSE = "close";
    private static final String STREAM_VALUE = "value";
    private static final String BAL_STREAM_NEXT = "next";
    
    private final Environment environment;
    private final BStream ballerinaStream;
    private byte[] currentChunk;
    private int chunkPosition;
    private boolean endOfStream;
    private final boolean hasCloseMethod;

    public BallerinaStreamInputStream(Environment environment, BStream ballerinaStream) {
        this.ballerinaStream = ballerinaStream;
        this.environment = environment;
        this.currentChunk = null;
        this.chunkPosition = 0;
        this.endOfStream = false;
        
        // Check if stream has a close method
        Type iteratorType = ballerinaStream.getIteratorObj().getOriginalType();
        if (iteratorType.getTag() == TypeTags.OBJECT_TYPE_TAG) {
            ObjectType iteratorObjectType = (ObjectType) iteratorType;
            MethodType[] methods = iteratorObjectType.getMethods();
            hasCloseMethod = java.util.Arrays.stream(methods)
                    .anyMatch(method -> method.getName().equals(BAL_STREAM_CLOSE));
        } else {
            hasCloseMethod = false;
        }
    }

    @Override
    public int read() throws IOException {
        if (endOfStream) {
            return -1;
        }

        // If no current chunk or exhausted, fetch next
        if (currentChunk == null || chunkPosition >= currentChunk.length) {
            if (!fetchNextChunk()) {
                endOfStream = true;
                return -1;
            }
        }

        return currentChunk[chunkPosition++] & 0xFF;
    }

    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        if (endOfStream) {
            return -1;
        }
        if (b == null) {
            throw new NullPointerException();
        } else if (off < 0 || len < 0 || len > b.length - off) {
            throw new IndexOutOfBoundsException();
        } else if (len == 0) {
            return 0;
        }

        int totalRead = 0;
        while (totalRead < len) {
            // Fetch next chunk if needed
            if (currentChunk == null || chunkPosition >= currentChunk.length) {
                if (!fetchNextChunk()) {
                    endOfStream = true;
                    return totalRead == 0 ? -1 : totalRead;
                }
            }

            // Copy from current chunk
            int available = currentChunk.length - chunkPosition;
            int toRead = Math.min(available, len - totalRead);
            System.arraycopy(currentChunk, chunkPosition, b, off + totalRead, toRead);
            chunkPosition += toRead;
            totalRead += toRead;
        }

        return totalRead;
    }

    private boolean fetchNextChunk() throws IOException {
        try {
            // Call next() method on the stream using Ballerina runtime
            Object result = environment.getRuntime().callMethod(
                    ballerinaStream.getIteratorObj(), BAL_STREAM_NEXT, null);
            
            if (result instanceof BError) {
                throw new IOException("Error reading from stream: " + ((BError) result).getMessage());
            }
            
            if (result == null) {
                return false;
            }
            
            if (result instanceof BMap) {
                BMap<?, ?> record = (BMap<?, ?>) result;
                Object value = record.get(StringUtils.fromString(STREAM_VALUE));
                
                if (value instanceof BArray) {
                    currentChunk = ((BArray) value).getBytes();
                    chunkPosition = 0;
                    return currentChunk.length > 0;
                } else {
                    throw new IOException("Unexpected value type in stream");
                }
            } else {
                throw new IOException("Unexpected result type from stream.next()");
            }
        } catch (Exception e) {
            throw new IOException("Error reading from Ballerina stream: " + e.getMessage(), e);
        }
    }

    @Override
    public void close() throws IOException {
        if (!hasCloseMethod) {
            return;
        }
        
        Object result = environment.getRuntime().callMethod(
                ballerinaStream.getIteratorObj(), BAL_STREAM_CLOSE, null);
        
        if (result instanceof BError) {
            throw new IOException(((BError) result).getMessage());
        }
        
        endOfStream = true;
        currentChunk = null;
    }
}
