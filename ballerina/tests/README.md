# Tests

This directory contains the test suite for the Ballerina AWS S3 connector. The tests cover all client operations including bucket management, object operations, multipart uploads, stream operations, presigned URLs, and client initialization with different authentication strategies.

## Authentication Strategies

The connector supports three ways to authenticate with AWS S3. The test suite is designed to work with all three — controlled by the `AUTH_TYPE` environment variable.

### 1. Static Credentials

Authenticates using an explicit AWS Access Key ID and Secret Access Key. This is the default method used when running tests in CI or locally with exported credentials.

**When it is used:** When `AUTH_TYPE` is not set and `ACCESS_KEY_ID` + `SECRET_ACCESS_KEY` are provided.

```ballerina
ConnectionConfig connectionConfig = {
    region: awsRegion,
    auth: {
        accessKeyId: accessKeyId,
        secretAccessKey: secretAccessKey
    }
};
Client s3Client = check new (connectionConfig);
```

**Environment variables required:**
```bash
export ACCESS_KEY_ID="<YOUR_ACCESS_KEY_ID>"
export SECRET_ACCESS_KEY="<YOUR_SECRET_ACCESS_KEY>"
export BUCKET_NAME="<YOUR_TEST_BUCKET_NAME>"
```

### 2. Profile-Based Credentials

Authenticates using a named profile from a local AWS credentials file. Useful when you manage multiple AWS accounts on your machine using the AWS CLI profile system.

**When it is used:** When `AUTH_TYPE=profile` is set.

```ballerina
ConnectionConfig connectionConfig = {
    region: awsRegion,
    auth: {
        profileName: "my-aws-profile",
        credentialsFilePath: "/home/user/.aws/credentials"
    }
};
Client s3Client = check new (connectionConfig);
```

**Environment variables required:**
```bash
export AUTH_TYPE="profile"
export AWS_PROFILE_NAME="<YOUR_AWS_PROFILE_NAME>"
export AWS_CREDENTIALS_FILE="<PATH_TO_CREDENTIALS_FILE>"
export BUCKET_NAME="<YOUR_TEST_BUCKET_NAME>"
```

### 3. Default Credential Provider Chain

Authenticates using the AWS SDK's default credential provider chain. The SDK automatically resolves credentials from the following sources in order:

1. Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
2. AWS credentials file (`~/.aws/credentials`)
3. ECS container credentials
4. EC2 instance profile / IAM role

This is the recommended method for production deployments on AWS infrastructure (EC2, ECS, Lambda).

**When it is used:** When `AUTH_TYPE=default` is set.

```ballerina
ConnectionConfig connectionConfig = {
    region: awsRegion,
    auth: DEFAULT_CREDENTIALS
};
Client s3Client = check new (connectionConfig);
```

**Environment variables required:**
```bash
export AUTH_TYPE="default"
export BUCKET_NAME="<YOUR_TEST_BUCKET_NAME>"
```

No explicit credentials are needed — the SDK resolves them automatically from the environment.

## Running the Tests

### With Static Credentials (most common)

```bash
export ACCESS_KEY_ID="<YOUR_ACCESS_KEY_ID>"
export SECRET_ACCESS_KEY="<YOUR_SECRET_ACCESS_KEY>"
export BUCKET_NAME="<YOUR_TEST_BUCKET_NAME>"

bal test
```

### With Profile-Based Credentials

```bash
export AUTH_TYPE="profile"
export AWS_PROFILE_NAME="<YOUR_AWS_PROFILE_NAME>"
export AWS_CREDENTIALS_FILE="$HOME/.aws/credentials"
export BUCKET_NAME="<YOUR_TEST_BUCKET_NAME>"

bal test
```

### With Default Credential Provider Chain

```bash
export AUTH_TYPE="default"
export BUCKET_NAME="<YOUR_TEST_BUCKET_NAME>"

bal test
```

## Enabling the Auth-Specific Test Cases

By default, only `testInitUsingStaticAuth` is enabled. The other two initialization tests are disabled because they require credentials that may not be available in all environments:

```ballerina
@test:Config {}
isolated function testInitUsingStaticAuth() returns error? { ... }

@test:Config {
    enable: false    // ← disabled by default
}
isolated function testInitUsingProfileAuth() returns error? { ... }

@test:Config {
    enable: false    // ← disabled by default
}
isolated function testInitUsingDefaultCredentials() returns error? { ... }
```

To run a specific initialization test, set `enable: true` for the relevant test case and ensure the corresponding environment variables are set before running `bal test`.

## Test Coverage

| Category | Test Cases |
|---|---|
| **Client initialization** | Static auth, profile auth, default credentials |
| **Bucket operations** | Create, list, get location, delete, delete with invalid name |
| **Object operations** | Put (string, JSON, XML, byte[], file), get (stream, text, JSON, XML, CSV), delete, copy, metadata, existence check |
| **Presigned URLs** | GET URL, PUT URL, invalid object name, invalid bucket name |
| **Stream operations** | Put as stream, put as stream with metadata, large file stream, direct stream |
| **Multipart uploads** | Create, upload part, upload part as stream, complete, abort, multiple parts |
| **Error handling** | Non-existent bucket, non-existent object, invalid file path, wrong region |

## Notes

- All tests run against a real AWS S3 bucket. There is no mock server involved except when no credentials are provided at all (in that case a `test:mock(Client)` is returned and live tests are skipped).
- The test bucket is created at the start of the suite and deleted in the `@test:AfterSuite` cleanup function, which also deletes any remaining objects first.
- Multipart upload tests use a minimum part size of 5MB as required by the AWS S3 API for all parts except the last.