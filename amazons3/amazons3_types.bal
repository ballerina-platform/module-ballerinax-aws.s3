//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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
//

import ballerina/http;

# Define the bucket type.
# + name - The name of the bucket
# + creationDate - The creation date of the bucket
public type Bucket record {
    string name = "";
    string creationDate = "";
};

# Define the S3Object type.
# + objectName - The name of the object
# + lastModified - The last modified date of the object
# + eTag - The etag of the object
# + objectSize - The size of the object
# + ownerId - The id of the object owner
# + ownerDisplayName - The display name of the object owner
# + storageClass - The storage class of the object
# + content - The content of the object
public type S3Object record {
    string objectName = "";
    string lastModified = "";
    string eTag = "";
    string objectSize = "";
    string ownerId = "";
    string ownerDisplayName = "";
    string storageClass = "";
    string content = "";
};

# Define the status type.
# + success - The status of the AmazonS3 operation
# + statusCode - The status code of the response
public type Status record {
    boolean success = false;
    int statusCode = 0;
};

