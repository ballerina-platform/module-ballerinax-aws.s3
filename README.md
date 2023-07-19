# Ballerina Amazon S3 Connector 
[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.s3.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-ballerinax-aws.s3)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.s3/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.s3)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.s3.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.s3./commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.s3/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.s3/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Amazon Simple Storage Service (Amazon S3)](https://aws.amazon.com/s3/) is an object storage service that offers industry-leading scalability, data availability, security, and performance. This means customers of all sizes and industries can use it to store and protect any amount of data for a range of use cases, such as data lakes, websites, mobile applications, backup and restore, archive, enterprise applications, IoT devices, and big data analytics.

The connector provides the capability to manage buckets and objects in AWS S3.
For more information about configuration and operations, go to the module.
- [aws.s3](s3/Module.md) -  Perform AWS S3 related operations programmatically.

## Building from the source
### Setting up the prerequisites
1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).
 
   > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.
 
2. Download and install [Ballerina Swan Lake](https://ballerina.io/)

### Building the source
 
Execute the commands below to build from the source:
* To build the package:
   ```   
   bal pack ./s3
   ```
* To run the tests after build:
   ```
   bal test ./s3
   ```
## Contributing to Ballerina
 
As an open source project, Ballerina welcomes contributions from the community.
 
For more information, see [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).
 
## Code of conduct
 
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).
 
## Useful links
 
* Discuss code changes of the Ballerina project via [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
 
