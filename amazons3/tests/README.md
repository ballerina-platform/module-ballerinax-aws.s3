# Ballerina Amazon S3 Connector Test

The Amazon S3 connector allows you to access the Amazon S3 REST API through ballerina.

## Compatibility
| Ballerina Version | Amazon S3 API Version |
|-------------------|---------------------- |
| 0.982.0           | 2006-03-01           |

###### Running tests

1. Create `ballerina.conf` file in `package-amazons3`, with following keys and provide values for the variables.
    
    ```.conf
    ACCESS_KEY_ID=""
    SECRET_ACCESS_KEY=""
    REGION=""
    BUCKET_NAME=""
    ```
2. Navigate to the folder package-amazons3

3. Run tests :

    ```ballerina
    ballerina init
    ballerina test amazons3 --config ballerina.conf
    ```
```