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

const string CSV_SEPARATOR = ",";
const string CSV_LINE_SEPARATOR = "\n";
const string EMPTY_STRING = "";

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
    } else if content is json {
        return content.toJsonString().toBytes();
    }
    return content.toString().toBytes();
}

# Collects all chunks from a byte stream into a single byte array.
#
# + byteStream - The byte stream to collect
# + return - The collected bytes or an Error
isolated function collectByteStream(stream<byte[], error?> byteStream) returns byte[]|Error {
    byte[] collected = [];
    error? e = from byte[] chunk in byteStream
        do {
            collected.push(...chunk);
        };
    if e is error {
        return error Error("Failed to read byte stream: " + e.message(), e);
    }
    return collected;
}

# Collects all records from a record stream into an array.
#
# + recordStream - The record stream to collect
# + return - The collected records or an Error
isolated function collectRecordStream(stream<record {}, error?> recordStream) returns record {}[]|Error {
    record {}[] records = [];
    error? e = from record {} rec in recordStream
        do {
            records.push(rec);
        };
    if e is error {
        return error Error("Failed to read record stream: " + e.message(), e);
    }
    return records;
}

isolated function convertRecordToXml(record {} rec, string objectKey) returns string {
    // Derive root element name from the object key filename (without extension)
    string rootName = "root";
    string key = objectKey;
    int? lastSlash = key.lastIndexOf("/");
    if lastSlash is int {
        key = key.substring(lastSlash + 1);
    }
    if key.toLowerAscii().endsWith(".xml") {
        rootName = key.substring(0, key.length() - 4);
    }

    string[] parts = [];
    parts.push(string `<${rootName}>`);
    foreach [string, anydata] [fieldName, value] in rec.entries() {
        string strVal = value is () ? "" : value.toString();
        parts.push(string `<${fieldName}>${strVal}</${fieldName}>`);
    }
    parts.push(string `</${rootName}>`);
    return string:'join("", ...parts);
}

isolated function convertRecordsToCsv(record {}[] records) returns byte[] {
    if records.length() == 0 {
        return [];
    }
    string[] headers = records[0].keys();
    string[] lines = [];
    lines.push(string:'join(CSV_SEPARATOR, ...headers));
    foreach record {} rec in records {
        string[] values = [];
        foreach string header in headers {
            anydata val = rec[header];
            values.push(val is () ? EMPTY_STRING : val.toString());
        }
        lines.push(string:'join(CSV_SEPARATOR, ...values));
    }
    return string:'join(CSV_LINE_SEPARATOR, ...lines).toBytes();
}
