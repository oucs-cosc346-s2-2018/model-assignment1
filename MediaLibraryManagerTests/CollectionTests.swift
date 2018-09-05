//
//  CollectionTests.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 29/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class CollectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        do {
            try writeAllToCurrentDirectory()
        } catch {
            XCTFail("Something went wrong removing test files from current working directory")
        }
    }

    override func tearDown() {
        do {
            try removeAllFromCurrentDirectory()
        } catch {
            XCTFail("Something went wrong removing test files from current working directory")
        }
        super.tearDown()
    }

    //swiftlint:disable:next todo
    //TODO: TEST what happens if multiple files are loaded?

    func testLoadCollection() {
        let collection = Collection()
        collection.load(filename: allTypesValidfilename)

        XCTAssert(!(collection.all().count < 4), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 4), "there are too many files in the collection")
    }

    func testAddToCollection() {
        let collection = Collection()
        collection.load(filename: allTypesValidfilename)

        XCTAssert(!(collection.all().count < 4), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 4), "there are too many files in the collection")

        let document = DocumentFile(
            path: "/created/by/code.doc",
            filename: "/created/by/code",
            creator: Metadata(keyword: "creator", value: "code"))

        collection.add(file: document)

        XCTAssert(!(collection.all().count < 5), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 5), "there are too many files in the collection")
    }

    func testSearchCollection() {
        let collection = Collection()
        collection.load(filename: allTypesValidfilename)

        // all the entries are created by Paul, and non by Hamza
        XCTAssert(collection.search(term: "Paul").count == 4, "Too many or too few entries")
        XCTAssert(collection.search(term: "Hamza").count == 0, "Too many or too few entries")

        // the image and video both have the same resolution
        XCTAssert(collection.search(term: "1024x768").count == 2, "Too many or too few entries")

        // the audio and video both have the same runtime
        XCTAssert(collection.search(term: "3mins").count == 2, "Too many or too few entries")
    }

    func testAddAndSearchCollection() {
        let collection = Collection()
        collection.load(filename: allTypesValidfilename)

        XCTAssert(!(collection.all().count < 4), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 4), "there are too many files in the collection")

        let creator = Metadata(keyword: "creator", value: "code")
        let document = DocumentFile(
            path: "/created/by/code.doc",
            filename: "/created/by/code",
            creator: creator)

        collection.add(file: document)

        XCTAssert(!(collection.all().count < 5), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 5), "there are too many files in the collection")

        // all the entries are created by Paul, and non by Hamza
        XCTAssert(collection.search(term: "Paul").count == 4, "Too many or too few entries")
        XCTAssert(collection.search(term: "code").count == 1, "Too many or too few entries")
        XCTAssert(collection.search(term: "Hamza").count == 0, "Too many or too few entries")

        // the image and video both have the same resolution
        XCTAssert(collection.search(term: "1024x768").count == 2, "Too many or too few entries")

        // the audio and video both have the same runtime
        XCTAssert(collection.search(term: "3mins").count == 2, "Too many or too few entries")
    }

    func testRemoveNonRequiredAndSearchCollection() {
        let collection = Collection()
        let creator = Metadata(keyword: "creator", value: "code")
        let other = Metadata(keyword: "foo", value: "bar")
        let document = DocumentFile(
            path: "/created/by/code.doc",
            filename: "/created/by/code",
            metadata: [creator, other],
            creator: creator)

        collection.add(file: document)

        XCTAssert(!(collection.all().count < 1), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 1), "there are too many files in the collection")
        XCTAssert(collection.search(term: "code").count == 1, "Too many or too few entries")
        XCTAssert(collection.search(term: "bar").count == 1, "Too many or too few entries")

        collection.remove(metadata: other)
        XCTAssert(!(collection.all().count < 1), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 1), "there are too many files in the collection")
        XCTAssert(collection.search(term: "code").count == 1, "Too many or too few entries")
        XCTAssert(collection.search(term: "bar").count == 0, "Too many or too few entries")

        let files = collection.search(term: "code")
        for file in files {
            // swiftlint:disable:next identifier_name
            for md in file.metadata {
                XCTAssert(!(md.keyword == other.keyword && md.value == other.value), "Metadata still in the file")
            }
        }
    }

    func testRemoveRequiredFromCollection() {
        let collection = Collection()
        let creator = Metadata(keyword: "creator", value: "code")
        let document = DocumentFile(
            path: "/created/by/code.doc",
            filename: "/created/by/code",
            metadata: [creator],
            creator: creator)

        collection.add(file: document)

        XCTAssert(!(collection.all().count < 1), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 1), "there are too many files in the collection")

        collection.remove(metadata: creator)

        XCTAssert(!(collection.all().count < 1), "there are too few files in the collection")
        XCTAssert(!(collection.all().count > 1), "there are too many files in the collection")

        let files = collection.all()

        XCTAssert(files.count > 0, "Missing data")

        if files.count > 0 {

            XCTAssert(files[0].metadata.count == 1, "Deleted too much data")

            if files[0].metadata.count > 0 {
                XCTAssert(files[0].metadata[0].keyword == document.metadata[0].keyword &&
                    files[0].metadata[0].value == document.metadata[0].value, "Deleted creator metadata")
            }
        }
    }

    func testMetadataSearchCollection() {
        let collection = Collection()
        collection.load(filename: allTypesValidfilename)

        // all the entries are created by Paul, and non by Hamza
        XCTAssert(
            collection.search(item: Metadata(keyword: "creator", value: "Paul")).count == 4,
            "Too many or too few entries")
        XCTAssert(
            collection.search(item: Metadata(keyword: "creator", value: "Hamza")).count == 0,
            "Too many or too few entries")

        // the image and video both have the same resolution
        XCTAssert(
            collection.search(item: Metadata(keyword: "resolution", value: "1024x768")).count == 2,
            "Too many or too few entries")

        // the audio and video both have the same runtime
        XCTAssert(
            collection.search(item: Metadata(keyword: "runtime", value: "3mins")).count == 2,
            "Too many or too few entries")
    }
}
