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

string[] alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s",
"t", "u", "v", "w", "x", "y", "z"];
string[] result = [];

type SortBucket object {

    string[] items = [];
    int index = 0;


    function sortBucket();

    public function addItem(string item) {
        self.items[self.items.length()] = item;
    }
};

function SortBucket.sortBucket() {
    map<any> buckets = bucketize(self.items, self.index);
    addToResultArray(buckets);
}

# Returns sorted string array after performing bucket sort repeatedly.
# By default, sorting is done on the english alphabet order.
# If any character outside the alphabet isfound, it will get the least priority in sorting.
#
# + unsortedArray - The unsorted string array.
# + return - The sorted string array.
public function sort(string[] unsortedArray) returns string[] {
    result = [];
    SortBucket initBucket = new SortBucket();
    initBucket.items = unsortedArray;
    initBucket.index = 0;
    initBucket.sortBucket();
    return result;
}

function bucketize(string[] strArray, int index) returns map<any> {
    map<any> bucketsMap = {};
    foreach string item in strArray {
        addToBucket(item, index, bucketsMap);
    }

    return bucketsMap;
}

function addToBucket(string item, int index, map<any> bucketsMap) {
    int nextIndex = index + 1;
    if (item.length() < nextIndex) {
        // Nothing to sort further, add to result
        result[result.length()] = item;
    }

    boolean matchFound = false;
    foreach var char in alphabet {
        if (item.substring(index, nextIndex).equalsIgnoreCase(char)) {
            populateMap(bucketsMap, char, item, index);
            matchFound = true;
            break;
        }
    }

    // Skip current character and consider next.
    if (!matchFound) {
        populateMap(bucketsMap, "nonAlp", item, index);
    }
}

function populateMap(map<any> bucketmap, string key, string item, int index) {
    if (bucketmap.hasKey(key)) {
        SortBucket buck = <SortBucket>bucketmap[key];
        buck.addItem(item);
        buck.index = index + 1;
    } else {
        SortBucket newBucket = new SortBucket();
        newBucket.addItem(item);
        newBucket.index = index + 1;
        bucketmap[key] = newBucket;
    }
}

function addToResultArray(map<any> buckets) {
    int i = 0;

    while (i < alphabet.length()) {
        string alpChar = alphabet[i];
        if (buckets.hasKey(alpChar)) {
            addToResultByKey(<SortBucket>buckets[alpChar]);
        }
        i = i + 1;
    }

    if (buckets.hasKey("nonAlp")) {
        addToResultByKey(<SortBucket>buckets["nonAlp"]);
    }
}

function addToResultByKey(SortBucket thisBucket) {
    if (thisBucket.items.length() > 1) {
        thisBucket.sortBucket(); // Create buckets again
    } else {
        // Only one item in the bucket
        result[result.length()] = thisBucket.items[0];
    }
}
