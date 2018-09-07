//
//  ValidationTests.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 28/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

// the tests we're performing are based around converting from JSON struct to File type
//
// for each file type:
//  1. complete valid data
//  2. missing creator (all files require creator)
//  3. missing other required metadata
//  4. missing optional metadata -- created
//
// a combination of all of the above cases (I want my importer to try its best)

class ValidationTests: XCTestCase {
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

    func testDocument() {
        let loader = JSONImporter()
        do {
            _ = try loader.read(filename: documentValidAndInvalidFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors {
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }

    func testImage() {
        let loader = JSONImporter()
        do {
            _ = try loader.read(filename: imageValidAndInvalidFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors {
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }

    func testVideo() {
        let loader = JSONImporter()
        do {
            _ = try loader.read(filename: videoValidAndInvalidFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors {
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }

    func testAudio() {
        let loader = JSONImporter()
        do {
            _ = try loader.read(filename: audioValidAndInvalidFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors {
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }
}
