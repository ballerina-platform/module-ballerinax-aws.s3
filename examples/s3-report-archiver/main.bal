// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
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

import ballerina/io;
import ballerina/log;
import ballerina/time;
import ballerinax/aws.s3;

configurable string s3AccessKeyId = ?;
configurable string s3SecretAccessKey = ?;
configurable string s3BucketName = ?;
configurable s3:Region s3Region = ?;

configurable string incomingPrefix = "reports/incoming/";
configurable string processedPrefix = "reports/processed/";
configurable string archivePrefix = "reports/archive/";
configurable int maxFileSizeBytes = 10000000;

type SalesRecord record {
    string date;
    string product;
    string region;
    int units;
    float revenue;
};

type ReportSummary record {
    string sourceKey;
    string processedKey;
    string archiveKey;
    int totalRows;
    int skippedRows;
    float totalRevenue;
    string topProduct;
    string lastModified;
    int fileSizeBytes;
};

type ArchiveStats record {
    int totalFound;
    int processed;
    int skipped;
    int failed;
    string[] errors;
};

public function main() returns error? {
    s3:Client s3Client = check new ({
        region: s3Region,
        auth: {
            accessKeyId: s3AccessKeyId,
            secretAccessKey: s3SecretAccessKey
        }
    });

    io:println("Starting S3 Report Archiver");
    io:println(string `Bucket: ${s3BucketName}, Region: ${s3Region}`);
    io:println(string `Incoming: ${incomingPrefix}`);
    io:println(string `Processed: ${processedPrefix}`);
    io:println(string `Archive: ${archivePrefix}`);

    ArchiveStats stats = check runArchiver(s3Client);
    printArchiveStats(stats);

    check s3Client.close();
}

function parseSalesRecords(string[][] rows) returns SalesRecord[]|error {
    SalesRecord[] records = [];

    foreach int i in 1 ..< rows.length() {
        string[] row = rows[i];

        if row.length() < 5 {
            continue;
        }

        int|error units = int:fromString(row[3].trim());
        float|error revenue = float:fromString(row[4].trim());

        if units is error || revenue is error {
            continue;
        }

        records.push({
            date: row[0].trim(),
            product: row[1].trim(),
            region: row[2].trim(),
            units: units,
            revenue: revenue
        });
    }

    return records;
}

function transformRecords(SalesRecord[] records) returns string[][] {
    SalesRecord[] filtered = records.filter(r => r.revenue > 0.0);

    SalesRecord[] sorted = from SalesRecord r in filtered
        order by r.revenue descending
        select r;

    string[][] output = [];
    output.push(["date", "product", "region", "units", "revenue", "running_total"]);

    float runningTotal = 0.0;
    foreach SalesRecord r in sorted {
        runningTotal += r.revenue;
        output.push([
            r.date,
            r.product,
            r.region,
            r.units.toString(),
            r.revenue.toString(),
            runningTotal.toString()
        ]);
    }

    return output;
}

function toCsvString(string[][] rows) returns string {
    string result = "";
    foreach int i in 0 ..< rows.length() {
        string[] row = rows[i];
        string line = "";
        foreach int j in 0 ..< row.length() {
            if j > 0 {
                line += ",";
            }
            line += row[j];
        }
        if i > 0 {
            result += "\n";
        }
        result += line;
    }
    return result;
}

function findTopProduct(SalesRecord[] records) returns string {
    map<float> productRevenue = {};

    foreach SalesRecord r in records {
        float current = productRevenue[r.product] ?: 0.0;
        productRevenue[r.product] = current + r.revenue;
    }

    string top = "N/A";
    float maxRev = 0.0;

    foreach [string, float] [product, rev] in productRevenue.entries() {
        if rev > maxRev {
            maxRev = rev;
            top = product;
        }
    }

    return top;
}

function sumRevenue(SalesRecord[] records) returns float {
    float total = 0.0;
    foreach SalesRecord r in records {
        total += r.revenue;
    }
    return total;
}

function extractFilename(string objectKey) returns string {
    string[] parts = re`/`.split(objectKey);
    return parts[parts.length() - 1];
}

function buildArchiveKey(string filename) returns string {
    time:Civil now = time:utcToCivil(time:utcNow());
    string month = now.month < 10 ? "0" + now.month.toString() : now.month.toString();
    string day = now.day < 10 ? "0" + now.day.toString() : now.day.toString();
    string dateStr = string `${now.year}-${month}-${day}`;
    return archivePrefix + dateStr + "/" + filename;
}

function buildProcessedKey(string filename) returns string {
    if filename.endsWith(".csv") {
        string base = filename.substring(0, filename.length() - 4);
        return processedPrefix + base + "_processed.csv";
    }
    return processedPrefix + filename + "_processed";
}

function processReport(s3:Client s3Client, string objectKey) returns ReportSummary|error {
    string filename = extractFilename(objectKey);
    log:printInfo(string `Processing: ${objectKey}`);

    s3:ObjectMetadata metadata = check s3Client->getObjectMetadata(s3BucketName, objectKey);

    int fileSize = 0;
    int? contentLen = metadata.contentLength;
    if contentLen is int {
        fileSize = contentLen;
    }

    string lastModified = "unknown";
    string? lastMod = metadata.lastModified;
    if lastMod is string {
        lastModified = lastMod;
    }

    log:printInfo(string `Size: ${fileSize} bytes, Last modified: ${lastModified}`);

    if fileSize > maxFileSizeBytes {
        return error(string `File too large: ${fileSize} bytes exceeds limit of ${maxFileSizeBytes} bytes`);
    }

    string[][] rawRows = check s3Client->getObjectAsCsv(s3BucketName, objectKey);
    log:printInfo(string `Parsed ${rawRows.length()} rows including header`);

    SalesRecord[] records = check parseSalesRecords(rawRows);
    int totalRows = records.length();
    string topProduct = findTopProduct(records);
    float totalRevenue = sumRevenue(records);

    string[][] transformed = transformRecords(records);
    int skippedRows = totalRows - (transformed.length() - 1);
    string csvContent = toCsvString(transformed);

    string processedKey = buildProcessedKey(filename);
    check s3Client->putObject(s3BucketName, processedKey, csvContent);
    log:printInfo(string `Uploaded processed file: ${processedKey}`);

    string archiveKey = buildArchiveKey(filename);
    check s3Client->copyObject(s3BucketName, objectKey, s3BucketName, archiveKey);
    log:printInfo(string `Archived original to: ${archiveKey}`);

    check s3Client->deleteObject(s3BucketName, objectKey);
    log:printInfo(string `Deleted original: ${objectKey}`);

    return {
        sourceKey: objectKey,
        processedKey: processedKey,
        archiveKey: archiveKey,
        totalRows: totalRows,
        skippedRows: skippedRows,
        totalRevenue: totalRevenue,
        topProduct: topProduct,
        lastModified: lastModified,
        fileSizeBytes: fileSize
    };
}

function runArchiver(s3:Client s3Client) returns ArchiveStats|error {
    ArchiveStats stats = {
        totalFound: 0,
        processed: 0,
        skipped: 0,
        failed: 0,
        errors: []
    };

    log:printInfo(string `Scanning prefix: ${incomingPrefix}`);

    s3:ListObjectsResponse listing = check s3Client->listObjects(s3BucketName, prefix = incomingPrefix);
    s3:S3Object[] allObjects = listing.objects;

    s3:S3Object[] csvFiles = from s3:S3Object obj in allObjects
        where obj.key.endsWith(".csv") && !obj.key.endsWith("/")
        select obj;

    stats.totalFound = csvFiles.length();
    log:printInfo(string `Found ${stats.totalFound} CSV files to process`);

    if stats.totalFound == 0 {
        log:printInfo("No CSV files found. Upload reports to the incoming prefix first.");
        return stats;
    }

    foreach s3:S3Object obj in csvFiles {
        string objectKey = obj.key;

        do {
            ReportSummary summary = check processReport(s3Client, objectKey);
            stats.processed += 1;
            printReportSummary(summary);
        } on fail error e {
            log:printError(string `Failed to process ${objectKey}: ${e.message()}`, 'error = e);
            stats.failed += 1;
            stats.errors.push(string `${objectKey}: ${e.message()}`);
        }
    }

    return stats;
}

function printReportSummary(ReportSummary s) {
    io:println("Report processed successfully:");
    io:println(string `  Source:      ${s.sourceKey}`);
    io:println(string `  Processed:   ${s.processedKey}`);
    io:println(string `  Archive:     ${s.archiveKey}`);
    io:println(string `  Total rows:  ${s.totalRows}, Filtered out: ${s.skippedRows}`);
    io:println(string `  Revenue:     ${s.totalRevenue}`);
    io:println(string `  Top product: ${s.topProduct}`);
    io:println(string `  File size:   ${s.fileSizeBytes} bytes`);
}

function printArchiveStats(ArchiveStats stats) {
    io:println("Sync Summary:");
    io:println(string `  Total found:  ${stats.totalFound}`);
    io:println(string `  Processed:    ${stats.processed}`);
    io:println(string `  Skipped:      ${stats.skipped}`);
    io:println(string `  Failed:       ${stats.failed}`);
    if stats.errors.length() > 0 {
        io:println("Errors:");
        foreach string err in stats.errors {
            io:println(string `  ${err}`);
        }
    }
}
