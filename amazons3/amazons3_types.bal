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

documentation {
    Define the Amazon S3 connector.
    F{{accessKeyId}} - The access key is of the Amazon S3 account.
    F{{secretAccessKey}} - The secret access key of the Amazon S3 account.
    F{{region}} - The AWS Region.
}
public type AmazonS3Connector object {
    public string accessKeyId;
    public string secretAccessKey;
    public string region;

    documentation {
        Retrieve the existing buckets.
        R{{}} - If success, returns BucketList object, else returns AmazonS3Error object.
    }
    public function getBucketList() returns Bucket[]|AmazonS3Error;

    documentation {
        Create a bucket.
        R{{}} - If success, returns Status object, else returns AmazonS3Error object.
    }
    public function createBucket(string bucketName) returns Status|AmazonS3Error;

    documentation {
        Retrieve the existing objects in a given bucket.
        P{{bucketName}} - The name of the bucket.
        R{{}} - If success, returns S3Object[] object, else returns AmazonS3Error object.
    }
    public function getAllObjects(string bucketName) returns S3Object[]|AmazonS3Error;

    documentation {
        Retrieves objects from Amazon S3.
        P{{bucketName}} - The name of the bucket.
        P{{objectName}} - The name of the object.
        R{{}} - If success, returns S3ObjectContent object, else returns AmazonS3Error object.
    }
    public function getObject(string bucketName, string objectName) returns S3Object|AmazonS3Error;

    documentation {
        Create an object.
        P{{objectName}} - The name of the object.
        P{{payload}} - The file that needed to be added to the bucket.
        R{{}} - If success, returns Status object, else returns AmazonS3Error object.
    }
    public function createObject(string bucketName, string objectName, string payload) returns Status|AmazonS3Error;

    documentation {
        Delete an object.
        P{{objectName}} - The name of the object.
        R{{}} - If success, returns Status object, else returns AmazonS3Error object.
    }
    public function deleteObject(string bucketName, string objectName) returns Status|AmazonS3Error;

    documentation {
        Delete a bucket.
        R{{}} - If success, returns Status object, else returns AmazonS3Error object.
    }
    public function deleteBucket(string bucketName) returns Status|AmazonS3Error;
};

documentation {
    AmazonS3 Client object
    E{{}}
    F{{amazonS3Config}} - AmazonS3 connector configurations.
    F{{amazonS3Connector}} - AmazonS3 Connector object.
}
public type Client object {

    public AmazonS3Configuration amazonS3Config = {};
    public AmazonS3Connector amazonS3Connector = new;

    documentation {
    AmazonS3 connector endpoint initialization function.
        P{{config}} - AmazonS3 connector configuration.
    }
    public function init(AmazonS3Configuration config);

    documentation {
    Return the AmazonS3 connector client.
        R{{}} - AmazonS3 connector client.
    }
    public function getCallerActions() returns AmazonS3Connector;

};

documentation {
    AmazonS3 connector configurations can be setup here
    F{{accessKeyId}} - The access key is of the Amazon S3 account.
    F{{secretAccessKey}} - The secret access key of the Amazon S3 account.
    F{{region}} - The AWS Region.
}
public type AmazonS3Configuration record {
    string accessKeyId;
    string secretAccessKey;
    string region;
};

documentation {
    Define the bucket type.
    F{{name}} - The name of the bucket.
    F{{creationDate}} - The creation date of the bucket.
}
public type Bucket record {
    string name;
    string creationDate;
};

documentation {
    Define the S3Object type.
    F{{objectName}} - The name of the object.
    F{{lastModified}} - The last modified date of the object.
    F{{eTag}} - The etag of the object.
    F{{objectSize}} - The size of the object.
    F{{ownerId}} - The id of the object owner.
    F{{ownerDisplayName}} - The display name of the object owner.
    F{{storageClass}} - The storage class of the object.
    F{{content}} - The content of the object.
}
public type S3Object record {
    string objectName;
    string lastModified;
    string eTag;
    string objectSize;
    string ownerId;
    string ownerDisplayName;
    string storageClass;
    string content;
};

documentation {
    Define the status type.
    F{{success}} - The status of the AmazonS3 operation.
    F{{statusCode}} - The status code of the response.
}
public type Status record {
    boolean success;
    int statusCode;
};

documentation {
    AmazonS3 Client Error.
    F{{message}} - Error message of the response.
    F{{cause}} - The error which caused the AmazonS3 error.
    F{{statusCode}} - Status code of the response.
}
public type AmazonS3Error record {
    string message;
    error? cause;
    int statusCode;
};
