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

# Configuration for the AWS S3 Listener.
public type ListenerConfiguration record {|
    *ConnectionConfig;
    # How often the listener polls the bucket for changes, in seconds (default: 60)
    decimal pollingInterval = 60;
    # Only listen for objects whose keys start with this prefix (e.g., "uploads/")
    string prefix?;
|};

# Event dispatched when a new object is created in the bucket.
public type CreatedEvent record {|
    # The name of the S3 bucket where the event occurred
    string bucketName;
    # Details of the newly created object
    S3Object 'object;
|};

# Event dispatched when an existing object is modified (its ETag changes).
public type UpdatedEvent record {|
    # The name of the S3 bucket where the event occurred
    string bucketName;
    # Details of the modified object (with the new ETag)
    S3Object 'object;
    # The ETag of the object before it was modified
    string previousETag;
|};

# Event dispatched when an object is deleted from the bucket.
public type DeletedEvent record {|
    # The name of the S3 bucket where the event occurred
    string bucketName;
    # The key of the deleted object
    string objectKey;
|};

# Represents an AWS S3 event listener service.
#
# Implement this service type and attach it to a `Listener` to receive S3 bucket
# change notifications. The listener polls the bucket at the configured interval and
# dispatches `onCreate`, `onUpdate`, and `onDelete` events as the bucket state changes.
#
# ```ballerina
# service s3:Service on s3Listener {
#     isolated remote function onCreate(s3:CreatedEvent event) returns error? {
#         log:printInfo("New object: " + event.'object.key);
#     }
#
#     isolated remote function onUpdate(s3:UpdatedEvent event) returns error? {
#         log:printInfo("Modified: " + event.'object.key);
#     }
#
#     isolated remote function onDelete(s3:DeletedEvent event) returns error? {
#         log:printInfo("Deleted: " + event.objectKey);
#     }
#
#     isolated remote function onError(error err) returns error? {
#         log:printError("Listener error", 'error = err);
#     }
# }
# ```
public type Service distinct isolated service object {
    // # Invoked when a new object is uploaded to the bucket.
    // #
    // # + event - Details of the created object
    // # + return - An `error` if handling fails, otherwise `()`
    // isolated remote function onCreate(CreatedEvent event) returns error?;

    // # Invoked when an existing object's content changes (ETag differs from last poll).
    // #
    // # + event - Details of the modified object and its previous ETag
    // # + return - An `error` if handling fails, otherwise `()`
    // isolated remote function onUpdate(UpdatedEvent event) returns error?;

    // # Invoked when an object is removed from the bucket.
    // #
    // # + event - The bucket name and key of the deleted object
    // # + return - An `error` if handling fails, otherwise `()`
    // isolated remote function onDelete(DeletedEvent event) returns error?;

    // # Invoked when the listener encounters an error during polling or event dispatch.
    // #
    // # + err - The error that occurred
    // # + return - An `error` if handling fails, otherwise `()`
    // isolated remote function onError(error err) returns error?;
};
