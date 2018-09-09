//
//  MediaLibraryManagerTests.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

/// This class is used to wrap the XCTAssert as a command object
//swiftlint:disable:next private_over_fileprivate
fileprivate class AssertCommand: MMCommand {
    var results: MMResultSet?
    var condition: () -> Bool
    var message: String

    /// Initialise the AssertCommand
    ///
    /// - Parameters:
    ///   - condition: function to evaluate
    ///   - message: mesage to show if the function returns false
    init(condition: @escaping () -> Bool, message: String) {
        self.condition = condition
        self.message = message
    }

    /// Execute the command by running the function
    ///
    /// - Throws: nothing
    func execute() throws {
        XCTAssert(self.condition(), self.message )
    }
}

class MediaLibraryManagerTests: XCTestCase {

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

    func executeCommand(_ command: MMCommand) -> MMResultSet {
        do {
            // try execute the command and catch any thrown errors below
            try command.execute()
            if let results = command.results {
                return results
            }
        } catch {
//            XCTFail(error.localizedDescription)
        }
        return MMResultSet([])
    }

    //swiftlint:disable:next function_body_length
    func testCollection() {
        let collection = Collection()
        var last: MMResultSet

        _ = executeCommand(HelpCommand())
        _ = executeCommand(AssertCommand(
            condition: {return collection.all().count == 0},
            message: "Collection not empty"))

        _ = executeCommand(LoadCommand(
            collection: collection,
            paths: [singleDocumentValidfilename]))

        _ = executeCommand(AssertCommand(
            condition: { return collection.all().count == 1},
            message: "Failed loading"))

        last = executeCommand(ListCommand(
            collection: collection,
            terms: ["Paul"]))

        _ = executeCommand(AssertCommand(
            condition: {return last.result().count == 1},
            message: "ResultSet after load is not correct"))

        last = executeCommand(AddMetadataCommand(
            collection: collection,
            items: last.result(),
            params: ["0", "foo", "bar"]))

        last = executeCommand(ListCommand(
            collection: collection,
            terms: ["bar"]))

        _ = executeCommand(AssertCommand(
            condition: {return last.result().count == 1},
            message: "ResultSet search 'bar' after add is not correct"))

        last = executeCommand(SetMetadataCommand(
            collection: collection,
            items: last.result(),
            params: ["0", "foo", "baz"]))

        last = executeCommand(ListCommand(
            collection: collection,
            terms: ["bar"]))

        _ = executeCommand(AssertCommand(
            condition: {return last.result().count == 0},
            message: "ResultSet search 'bar' after change is not correct"))

        last = executeCommand(ListCommand(
            collection: collection,
            terms: ["baz"]))

        _ = executeCommand(AssertCommand(
            condition: {return last.result().count == 1},
            message: "ResultSet search 'baz' after change is not correct"))

        last = executeCommand(DelMetadataCommand(
            collection: collection,
            items: last.result(),
            params: ["0", "foo", "baz"]))

        last = executeCommand(ListCommand(
            collection: collection,
            terms: ["baz"]))

        _ = executeCommand(AssertCommand(
            condition: {return last.result().count == 0},
            message: "ResultSet search 'foo' after delete is not correct"))

        last = executeCommand(ListCommand(
            collection: collection,
            terms: ["Paul"]))

        _ = executeCommand(AssertCommand(
            condition: {return last.result().count == 1},
            message: "ResultSet search 'Paul' is not correct"))

        _ = executeCommand(
            SaveCommand(collection: collection, filename: ["testing-data.json"], items: collection.all())
        )

        //swiftlint:disable:next identifier_name
        let c2: Collection = Collection()
        _ = executeCommand(LoadCommand(
            collection: c2,
            paths: ["testing-data.json"]))

        XCTAssert(collection.description == c2.description, "save->load not imdopentent!")
    }

}
