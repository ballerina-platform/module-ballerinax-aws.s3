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

import ballerina/jballerina.java;
import ballerina/task;

# Represents an AWS S3 listener that polls a bucket for object changes.
#
# The listener periodically calls `ListObjects` on the configured bucket, compares
# the result with the previously seen state, and dispatches `onCreate`, `onUpdate`,
# and `onDelete` events to the attached service.
#
# ```ballerina
# listener s3:Listener s3Listener = check new (
#     "my-bucket",
#     auth = {
#         accessKeyId: accessKeyId,
#         secretAccessKey: secretAccessKey
#     },
#     region = s3:US_EAST_1
# );
# ```
@display {label: "AWS S3 Listener", iconPath: "icon.png"}
public isolated class Listener {

    private Service? attachedService = ();
    private final decimal pollingInterval;
    private task:JobId? jobId = ();

    # Initializes the S3 Listener.
    # ```ballerina
    # listener s3:Listener s3Listener = check new (
    #     "my-bucket",
    #     auth = {
    #         accessKeyId: accessKeyId,
    #         secretAccessKey: secretAccessKey
    #     }
    # );
    # ```
    #
    # + bucketName - The name of the S3 bucket to monitor
    # + config - Listener configuration (auth, region, polling interval, optional prefix)
    # + return - An `Error` if initialization fails, otherwise `()`
    public isolated function init(string bucketName, *ListenerConfiguration config) returns Error? {
        self.pollingInterval = config.pollingInterval;
        return initListener(self, bucketName, config);
    }

    # Attaches an S3 service to the listener.
    # ```ballerina
    # check s3Listener.attach(s3Service);
    # ```
    #
    # + 'service - The service instance to attach
    # + name - The service name (unused for S3 listener)
    # + return - An `Error` if attaching fails, otherwise `()`
    public isolated function attach(Service 'service, string[]|string? name = ()) returns Error? {
        lock {
            self.attachedService = 'service;
        }
    }

    # Detaches an S3 service from the listener.
    # ```ballerina
    # check s3Listener.detach(s3Service);
    # ```
    #
    # + 'service - The service instance to detach
    # + return - An `Error` if detaching fails, otherwise `()`
    public isolated function detach(Service 'service) returns Error? {
        lock {
            self.attachedService = ();
        }
    }

    # Starts the listener and begins polling the S3 bucket for changes.
    # ```ballerina
    # check s3Listener.'start();
    # ```
    #
    # + return - An `Error` if starting fails, otherwise `()`
    public isolated function 'start() returns Error? {
        decimal interval;
        lock {
            interval = self.pollingInterval;
        }
        task:JobId|task:Error jid = task:scheduleJobRecurByFrequency(new S3PollingJob(self), interval);
        if jid is task:Error {
            return error Error("Failed to start S3 listener", jid);
        }
        lock {
            self.jobId = jid;
        }
    }

    # Gracefully stops the listener.
    # ```ballerina
    # check s3Listener.gracefulStop();
    # ```
    #
    # + return - An `Error` if stopping fails, otherwise `()`
    public isolated function gracefulStop() returns Error? {
        task:JobId? jid;
        lock {
            jid = self.jobId;
        }
        if jid is task:JobId {
            task:Error? err = task:unscheduleJob(jid);
            if err is task:Error {
                return error Error("Failed to stop S3 listener", err);
            }
            lock {
                self.jobId = ();
            }
        }
    }

    # Immediately stops the listener.
    # ```ballerina
    # check s3Listener.immediateStop();
    # ```
    #
    # + return - An `Error` if stopping fails, otherwise `()`
    public isolated function immediateStop() returns Error? {
        return self.gracefulStop();
    }

    // Runs one poll cycle. Called by S3PollingJob.execute() on each interval.
    isolated function poll() returns Error? {
        Service? svc;
        lock {
            svc = self.attachedService;
        }
        if svc is () {
            return;
        }
        return nativePoll(self, svc);
    }
}

// S3PollingJob implements task:Job (structurally) to drive the polling loop via
// task:scheduleJobRecurByFrequency. Unlike task:Service, task:Job.execute() is
// public so it can be implemented across modules without restriction.
isolated class S3PollingJob {
    private final Listener s3Listener;

    isolated function init(Listener s3Listener) {
        self.s3Listener = s3Listener;
    }

    // Called by the task scheduler on each interval. Fatal errors (e.g. bucket
    // deleted) are dispatched to the service's onError handler inside poll() before
    // returning, so they are handled at the Ballerina level rather than surfaced here.
    public function execute() {
        do {
            check self.s3Listener.poll();
        } on fail {
            // error already dispatched to onError handler inside poll()
        }
    }
}

isolated function initListener(Listener listenerObj, string bucketName, ListenerConfiguration config) returns Error? =
    @java:Method {
        name: "init",
        'class: "io.ballerina.lib.aws.s3.ListenerActions"
    } external;

isolated function nativePoll(Listener listenerObj, Service 'service) returns Error? =
    @java:Method {
        name: "poll",
        'class: "io.ballerina.lib.aws.s3.ListenerActions"
    } external;
