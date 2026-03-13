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

# Validates if a bucket name follows AWS naming conventions.
#
# + bucketName - The name of the bucket
# + return - True if valid, False otherwise
isolated function isValidBucketName(string bucketName) returns boolean {
    // 1. Length check (3-63 chars)
    if bucketName.length() < 3 || bucketName.length() > 63 {
        return false;
    }
    
    // 2. Regex check: Lowercase letters, numbers, hyphens, and dots only.
    // Must start and end with a letter or number.
    string:RegExp bucketPattern = re `^[a-z0-9][a-z0-9-.]*[a-z0-9]$`;
    return bucketPattern.isFullMatch(bucketName);
}

# Utility to convert common error messages to user-friendly text.
# 
# + err - The error returned from the client
# + return - A cleaned up string message
isolated function getErrorMessage(Error err) returns string {
    return err.message();
}

# Converts various ObjectContent types to a byte array.
# 
# + content - The ObjectContent to convert
# + return - The byte array representation or an Error
isolated function toByteArray(anydata content) returns byte[] {
    if content is byte[] {
        return content;
    } else if content is string {
        return content.toBytes();
    } else if content is xml {
        return content.toString().toBytes();
    }
    return content.toString().toBytes();
}
