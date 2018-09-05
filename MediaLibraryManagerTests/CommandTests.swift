//
//  CommandTests.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 3/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class CommandTests: XCTestCase {

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

    func testLoadAndListAllCommands() {
        let collection = Collection()
        let path = allTypesValidfilename

        let commands: [MMCommand] = [
                LoadCommand(collection: collection, paths: [path]),
                ListCommand(collection: collection, terms: [])
        ]

        var results: [MMResultSet?] = []

        for command in commands {
            do {
                try command.execute()
                results.append(command.results)
            } catch {
                XCTFail("Unexpected exception")
            }
        }

        XCTAssert(collection.all().count == 4, "Wrong number of files imported")

        // this works because *all* the files in the collection are
        // created by the same person
        if let last = results.last {
            XCTAssert(last?.result().count == collection.all().count,
                    "Not all files found when looking for creator 'Paul'")
        }
    }

    func testLoadAndListPaulCommands() {
        let collection = Collection()
        let path = allTypesValidfilename

        let commands: [MMCommand] = [
            LoadCommand(collection: collection, paths: [path]),
            ListCommand(collection: collection, terms: ["Paul"])
        ]

        var results: [MMResultSet?] = []

        for command in commands {
            do {
                try command.execute()
                results.append(command.results)
            } catch {
                XCTFail("Unexpected exception")
            }
        }

        XCTAssert(collection.all().count == 4, "Wrong number of files imported")

        // this works because *all* the files in the collection are
        // created by the same person
        if let last = results.last {
            XCTAssert(last?.result().count == collection.all().count,
                      "Not all files found when looking for creator 'Paul'")
        }
    }
}
