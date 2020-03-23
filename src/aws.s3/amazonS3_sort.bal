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

import ballerina/stringutils;

final string[] alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s",
"t", "u", "v", "w", "x", "y", "z"];
const string NON_ALPHABET = "nonAlp";

type SortBucket object {

    string[] items = [];
    int index = 0;
    string[] result = [];

    function sortBucket() {
        map<any> buckets = bucketize(self.items, self.index, self.result);
        addToResultArray(buckets, self.result);
    }

    function addItem(string item) {
        self.items[self.items.length()] = item;
    }
};

# Returns sorted string array after performing bucket sort repeatedly.
# By default, sorting is done on the english alphabet order.
# If any character outside the alphabet isfound, it will get the least priority in sorting.
#
# + unsortedArray - The unsorted string array.
# + return - The sorted string array.
public function sort(string[] unsortedArray) returns string[] {
    string[] resultArr = [];
    SortBucket initBucket = new SortBucket();
    initBucket.items = unsortedArray;
    initBucket.index = 0;
    initBucket.result = resultArr;
    initBucket.sortBucket();
    return initBucket.result;
}

function bucketize(string[] strArray, int index, string[] result) returns map<any> {
    map<any> bucketsMap = {};
    foreach string item in strArray {
        addToBucket(item, index, bucketsMap, result);
    }

    return bucketsMap;
}

function addToBucket(string item, int index, map<any> bucketsMap, string[] result) {
    int nextIndex = index + 1;
    if (item.length() < nextIndex) {
        // Nothing to sort further, add to result
        result[result.length()] = item;
    }

    boolean matchFound = false;
    foreach var char in alphabet {
        if (stringutils:equalsIgnoreCase(item.substring(index, nextIndex), char)) {
            populateMap(bucketsMap, char, item, index, result);
            matchFound = true;
            break;
        }
    }

    // Skip current character and consider next.
    if (!matchFound) {
        populateMap(bucketsMap, NON_ALPHABET, item, index, result);
    }
}

function populateMap(map<any> bucketmap, string key, string item, int index, string[] result) {
    if (bucketmap.hasKey(key)) {
        SortBucket buck = <SortBucket>bucketmap[key];
        buck.addItem(item);
        buck.index = index + 1;
        buck.result = result;
    } else {
        SortBucket newBucket = new SortBucket();
        newBucket.addItem(item);
        newBucket.index = index + 1;
        newBucket.result = result;
        bucketmap[key] = newBucket;
    }
}

function addToResultArray(map<any> buckets, string[] result) {
    int i = 0;

    while (i < alphabet.length()) {
        string alpChar = alphabet[i];
        if (buckets.hasKey(alpChar)) {
            addToResultByKey(<SortBucket>buckets[alpChar], result);
        }
        i = i + 1;
    }

    if (buckets.hasKey(NON_ALPHABET)) {
        addToResultByKey(<SortBucket>buckets[NON_ALPHABET], result);
    }
}

function addToResultByKey(SortBucket thisBucket, string[] result) {
    if (thisBucket.items.length() > 1) {
        thisBucket.sortBucket(); // Create buckets again
    } else {
        // Only one item in the bucket
        result[result.length()] = thisBucket.items[0];
    }
}
