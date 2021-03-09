// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

xmlns "http://s3.amazonaws.com/doc/2006-03-01/";

isolated function getBucketsList(xml response) returns Bucket[] {
    Bucket[] buckets = [];
    xml bucketsDetails = response/<Buckets>;
    int i = 0;
    foreach var b in bucketsDetails/<*> {
        xml bucketDetails = b.elements();
        Bucket bucket = {name: (bucketDetails/<Name>/*).toString(),
                        creationDate: (bucketDetails/<CreationDate>/*).toString()};
        buckets[i]= bucket;
        
        i = i + 1;
    }
    return buckets;
}

isolated function getS3ObjectsList(xml response) returns S3Object[] {
    S3Object[] s3Objects = [];
    xml contents = response/<Contents>;
    int i = 0;
    foreach var c in contents {
        xml content = c.elements();
        S3Object s3Object = {};
        s3Object.objectName = (content/<Key>/*).toString();
        s3Object.lastModified = (content/<LastModified>/*).toString();
        s3Object.eTag = (content/<ETag>/*).toString();
        s3Object.objectSize = (content/<Size>/*).toString();
        s3Object.ownerId = (content/<Owner>/<ID>/*).toString();
        s3Object.ownerDisplayName = (content/<Owner>/<DisplayName>/*).toString();
        s3Object.storageClass = (content/<StorageClass>/*).toString();
        s3Objects[i] = s3Object;
        
        i = i + 1;
    }
    return s3Objects;
}

isolated function getS3Object(byte[] response) returns S3Object {
    S3Object s3Object = {};
    s3Object.content =  response;
    return s3Object;
}
