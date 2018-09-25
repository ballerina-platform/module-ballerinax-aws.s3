[![Build Status](https://travis-ci.org/wso2-ballerina/package-amazons3.svg?branch=master)](https://travis-ci.org/wso2-ballerina/package-amazons3)

# Ballerina Amazon S3 Connector

The Amazon S3 connector allows you to access the Amazon S3 REST API through ballerina. The following section provide you the details on connector operations.

## Compatibility
| Ballerina Language Version | Amazon S3 API version  |
| -------------------------- | -------------------- |
| 0.981.0                    | 2006-03-01                  |


The following sections provide you with information on how to use the Ballerina Amazon S3 connector.

- [Contribute To Develop](#contribute-to-develop)
- [Working with Amazon S3 Connector actions](#working-with-amazon-s3-endpoint-actions)
- [Sample](#sample)

### Contribute To develop

Clone the repository by running the following command 
```shell
git clone https://github.com/wso2-ballerina/package-amazons3.git
```

### Working with Amazon S3 Connector 

First, import the `wso2/amazons3` package into the Ballerina project.

```ballerina
import wso2/amazons3;
```

In order for you to use the Amazon S3 Connector, first you need to create an AmazonS3 Client endpoint.

```ballerina
endpoint amazons3:Client amazonS3Client {
    accessKeyId:"",
    secretAccessKey:"",
    region:""
};
```

##### Sample

```ballerina
import ballerina/io;
import wso2/amazons3;

function main(string... args) {
    endpoint amazons3:Client amazonS3Client {
        accessKeyId:"",
        secretAccessKey:"",
        region:""
    };

    string bucketName = "testBallerina";
    var createBucketResponse = amazonS3Client -> createBucket(bucketName);
    match createBucketResponse {
        amazons3:Status bucketStatus => {
            //If successful, returns the status value as true.
            boolean status = <string> bucketStatus.success;
            io:println("Bucket Status: " + status);
        }
        //Unsuccessful attempts return an AmazonS3 error.
        amazons3:AmazonS3Error e => io:println(e);
    }
}
```
