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

import ballerina/lang.runtime;
import ballerina/random;
import ballerina/test;

isolated string[] listenerCreatedKeys = [];
isolated string[] listenerModifiedKeys = [];
isolated string[] listenerDeletedKeys = [];
isolated string[] listenerErrors = [];

isolated service class ListenerTestService {
    *Service;

    isolated remote function onCreate(CreatedEvent event) returns error? {
        lock {
            listenerCreatedKeys.push(event.'object.key);
        }
    }

    isolated remote function onUpdate(UpdatedEvent event) returns error? {
        lock {
            listenerModifiedKeys.push(event.'object.key);
        }
    }

    isolated remote function onDelete(DeletedEvent event) returns error? {
        lock {
            listenerDeletedKeys.push(event.objectKey);
        }
    }

    isolated remote function onError(error err) returns error? {
        lock {
            listenerErrors.push(err.message());
        }
    }
}

const decimal POLL_INTERVAL = 2;
const decimal POLL_WAIT = 6;

const string LISTENER_TEST_KEY = "listener-test-object.txt";
const string LISTENER_PREFIX_KEY = "uploads/listener-prefix-object.txt";
const string LISTENER_OUTSIDE_PREFIX_KEY = "other/outside-prefix.txt";

final string listenerBucketName = "ballerina-s3-listener-" + (check random:createIntInRange(100, 999999)).toString();

Listener? testS3Listener = ();

@test:Config {}
function testListenerBucketCreate() returns error? {
    if accessKeyId == "" {
        return;
    }
    check s3Client->createBucket(listenerBucketName);
}

@test:Config {
    dependsOn: [testListenerBucketCreate]
}
function testListenerStart() returns error? {
    if accessKeyId == "" {
        return;
    }
    Listener s3Listener = check new (
        listenerBucketName,
        auth = staticAuth,
        region = awsRegion,
        pollingInterval = POLL_INTERVAL
    );
    check s3Listener.attach(new ListenerTestService());
    check s3Listener.'start();
    testS3Listener = s3Listener;
}

@test:Config {
    dependsOn: [testListenerStart]
}
function testListenerOnCreateEvent() returns error? {
    if accessKeyId == "" {
        return;
    }
    check s3Client->putObject(listenerBucketName, LISTENER_TEST_KEY, "initial content");
    runtime:sleep(POLL_WAIT);

    boolean found;
    lock {
        found = listenerCreatedKeys.indexOf(LISTENER_TEST_KEY) != ();
    }
    test:assertTrue(found, msg = string `Expected onCreate event for '${LISTENER_TEST_KEY}'`);
}

@test:Config {
    dependsOn: [testListenerOnCreateEvent]
}
function testListenerOnModifyEvent() returns error? {
    if accessKeyId == "" {
        return;
    }
    // Upload different content so the ETag changes, triggering onUpdate.
    check s3Client->putObject(listenerBucketName, LISTENER_TEST_KEY, "modified content");
    runtime:sleep(POLL_WAIT);

    boolean found;
    lock {
        found = listenerModifiedKeys.indexOf(LISTENER_TEST_KEY) != ();
    }
    test:assertTrue(found, msg = string `Expected onUpdate event for '${LISTENER_TEST_KEY}'`);
}

@test:Config {
    dependsOn: [testListenerOnModifyEvent]
}
function testListenerOnDeleteEvent() returns error? {
    if accessKeyId == "" {
        return;
    }
    check s3Client->deleteObject(listenerBucketName, LISTENER_TEST_KEY);
    runtime:sleep(POLL_WAIT);

    boolean found;
    lock {
        found = listenerDeletedKeys.indexOf(LISTENER_TEST_KEY) != ();
    }
    test:assertTrue(found, msg = string `Expected onDelete event for '${LISTENER_TEST_KEY}'`);
}

@test:Config {
    dependsOn: [testListenerOnDeleteEvent]
}
function testListenerNoModifyEventForSameContent() returns error? {
    if accessKeyId == "" {
        return;
    }
    // Upload the object for the first time.
    check s3Client->putObject(listenerBucketName, LISTENER_TEST_KEY, "stable content");
    runtime:sleep(POLL_WAIT);

    // Clear the modify log, then re-upload with identical content.
    lock {
        listenerModifiedKeys = [];
    }
    check s3Client->putObject(listenerBucketName, LISTENER_TEST_KEY, "stable content");
    runtime:sleep(POLL_WAIT);

    boolean modifyFired;
    lock {
        modifyFired = listenerModifiedKeys.indexOf(LISTENER_TEST_KEY) != ();
    }
    test:assertFalse(modifyFired,
        msg = "onUpdate should NOT fire when object content (ETag) is unchanged");

    // Clean up: delete so following tests start with an empty bucket.
    check s3Client->deleteObject(listenerBucketName, LISTENER_TEST_KEY);
    runtime:sleep(POLL_WAIT);
}


@ServiceConfig {
    path: "uploads/"
}
isolated service class PrefixedListenerTestService {
    *Service;

    isolated remote function onCreate(CreatedEvent event) returns error? {
        lock {
            listenerCreatedKeys.push(event.'object.key);
        }
    }

    isolated remote function onUpdate(UpdatedEvent event) returns error? {
        lock {
            listenerModifiedKeys.push(event.'object.key);
        }
    }

    isolated remote function onDelete(DeletedEvent event) returns error? {
        lock {
            listenerDeletedKeys.push(event.objectKey);
        }
    }

    isolated remote function onError(error err) returns error? {
        lock {
            listenerErrors.push(err.message());
        }
    }
}

@test:Config {
    dependsOn: [testListenerNoModifyEventForSameContent]
}
function testListenerPrefixFilterSetup() returns error? {
    if accessKeyId == "" {
        return;
    }
    Listener? l = testS3Listener;
    if l is Listener {
        check l.gracefulStop();
    }
    lock { listenerCreatedKeys = []; }
    lock { listenerModifiedKeys = []; }
    lock { listenerDeletedKeys = []; }

    Listener prefixListener = check new (
        listenerBucketName,
        auth = staticAuth,
        region = awsRegion,
        pollingInterval = POLL_INTERVAL
    );
    check prefixListener.attach(new PrefixedListenerTestService());
    check prefixListener.'start();
    testS3Listener = prefixListener;
}

@test:Config {
    dependsOn: [testListenerPrefixFilterSetup]
}
function testListenerPrefixFilterOnlyMatchingKeyFires() returns error? {
    if accessKeyId == "" {
        return;
    }
    // Upload one object inside the prefix and one outside.
    check s3Client->putObject(listenerBucketName, LISTENER_PREFIX_KEY, "inside prefix");
    check s3Client->putObject(listenerBucketName, LISTENER_OUTSIDE_PREFIX_KEY, "outside prefix");
    runtime:sleep(POLL_WAIT);

    boolean insideFired;
    boolean outsideFired;
    lock {
        insideFired = listenerCreatedKeys.indexOf(LISTENER_PREFIX_KEY) != ();
        outsideFired = listenerCreatedKeys.indexOf(LISTENER_OUTSIDE_PREFIX_KEY) != ();
    }
    test:assertTrue(insideFired,
        msg = string `Expected onCreate for key inside prefix: '${LISTENER_PREFIX_KEY}'`);
    test:assertFalse(outsideFired,
        msg = string `Did NOT expect onCreate for key outside prefix: '${LISTENER_OUTSIDE_PREFIX_KEY}'`);

    // Clean up objects.
    check s3Client->deleteObject(listenerBucketName, LISTENER_PREFIX_KEY);
    check s3Client->deleteObject(listenerBucketName, LISTENER_OUTSIDE_PREFIX_KEY);
}

@test:Config {
    dependsOn: [testListenerPrefixFilterOnlyMatchingKeyFires]
}
function testListenerGracefulStop() returns error? {
    Listener? l = testS3Listener;
    if l is () {
        return;
    }
    check l.gracefulStop();
    testS3Listener = ();

    // Uploading after stop should produce no further events.
    lock {
        listenerCreatedKeys = [];
    }
    if accessKeyId != "" {
        check s3Client->putObject(listenerBucketName, LISTENER_TEST_KEY, "post-stop content");
        runtime:sleep(POLL_WAIT);
        boolean firedAfterStop;
        lock {
            firedAfterStop = listenerCreatedKeys.indexOf(LISTENER_TEST_KEY) != ();
        }
        test:assertFalse(firedAfterStop,
            msg = "No events should fire after the listener has been stopped");
        check s3Client->deleteObject(listenerBucketName, LISTENER_TEST_KEY);
    }
}

@test:Config {
    dependsOn: [testListenerGracefulStop]
}
function testListenerBucketDelete() returns error? {
    if accessKeyId == "" {
        return;
    }
    check s3Client->deleteBucket(listenerBucketName);
}
