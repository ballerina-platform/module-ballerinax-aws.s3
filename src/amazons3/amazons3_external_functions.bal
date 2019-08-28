// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerinax/java;

function lastIndexOf(handle originalText, handle str) returns int = @java:Method {
    name: "lastIndexOf",
    class: "java.lang.String",
    paramTypes: ["java.lang.String"]
} external;

function replace(handle originalText, handle textToReplace, handle replacement) returns handle = @java:Method {
    name: "replace",
    class: "java.lang.String",
    paramTypes: ["java.lang.String", "java.lang.String"]
} external;

function replaceFirst(handle originalText, handle textToReplace, handle replacement) returns handle = @java:Method {
    name: "replaceFirst",
    class: "java.lang.String",
    paramTypes: ["java.lang.String", "java.lang.String"]
} external;