//
//  IndexerTests.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 7/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class IndexerTests: XCTestCase {

    func testAddFileToIndex() {
        let indexer = Indexer()
        let document = DocumentFile(path: "/path/to",
                                    filename: "foobar.ext",
                                    creator: Metadata(keyword: "creator", value: "Paul"))

        XCTAssert(DocumentFile.validator.validate(data: document.metadata).count == 0,
                  "Errors encountered while validating document")

        indexer.add(file: document)
        let search = indexer.search(term: "Paul")
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }
    }

    func testAddMetadata() {
        let indexer = Indexer()
        var document = DocumentFile(path: "/path/to",
                                    filename: "foobar.ext",
                                    creator: Metadata(keyword: "creator", value: "Paul"))

        XCTAssert(DocumentFile.validator.validate(data: document.metadata).count == 0,
                  "Errors encountered while validating document")

        indexer.add(file: document)
        var search = indexer.search(term: "Paul")
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }

        let metadata = Metadata(keyword: "foo", value: "bar")
        document.add(keyword: metadata.keyword, value: metadata.value)
        indexer.add(term: metadata.value, file: document)

        search = indexer.search(term: "Paul")
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }

        search = indexer.search(term: "bar")
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }
    }
    func testSetMetadata() {
        let indexer = Indexer()
        var document = DocumentFile(path: "/path/to",
                                    filename: "foobar.ext",
                                    creator: Metadata(keyword: "creator", value: "Paul"))

        XCTAssert(DocumentFile.validator.validate(data: document.metadata).count == 0,
                  "Errors encountered while validating document")

        indexer.add(file: document)
        var search = indexer.search(term: "Paul")
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }

        let metadata = Metadata(keyword: "foo", value: "bar")
        document.add(keyword: metadata.keyword, value: metadata.value)
        indexer.add(term: metadata.value, file: document)

        search = indexer.search(term: metadata.value)
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }

        indexer.remove(term: metadata.value, f: document)
        metadata.value = "baz"
        document.edit(keyword: metadata.keyword, value: metadata.value)
        indexer.add(term: metadata.value, file: document)

        search = indexer.search(term: metadata.value)
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }
    }

    func testDelMetadata() {
        let indexer = Indexer()
        var document = DocumentFile(path: "/path/to",
                                    filename: "foobar.ext",
                                    creator: Metadata(keyword: "creator", value: "Paul"))

        XCTAssert(DocumentFile.validator.validate(data: document.metadata).count == 0,
                  "Errors encountered while validating document")

        indexer.add(file: document)
        var search = indexer.search(term: "Paul")
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }

        let metadata = Metadata(keyword: "foo", value: "bar")
        document.add(keyword: metadata.keyword, value: metadata.value)
        indexer.add(term: metadata.value, file: document)

        search = indexer.search(term: metadata.value)
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 1, "Missing data from Indexer")
        }

        indexer.remove(term: metadata.value, f: document)
        search = indexer.search(term: metadata.value)
        XCTAssertNotNil(search)
        if let result = search {
            XCTAssert(result.count == 0, "Too much data in Indexer")
        }
    }
}
