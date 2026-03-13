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

# Represents the base error type for the AWS S3 module.
public type Error distinct error;

# Represents an error returned from AWS S3 service.
public type S3Error distinct Error;

# Represents an error when the specified key does not exist.
public type NoSuchKeyError distinct S3Error;

# Represents an error when trying to create a bucket that already exists.
public type BucketAlreadyExistsError distinct S3Error;

# Represents an error when the bucket already exists and is owned by you.
public type BucketAlreadyOwnedByYouError distinct S3Error;

# Represents an error when the specified bucket does not exist.
public type NoSuchBucketError distinct S3Error;

# Represents an error when the bucket is not empty (for deletion).
public type BucketNotEmptyError distinct S3Error;

# Represents a client-side error.
public type ClientError distinct Error;
