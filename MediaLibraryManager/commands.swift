//
//  commands.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 15/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

// I'm reusing the MMCliError enum and MMResultSet class. If you want to
// *replace* the cli.swift, then you need to uncomment the parts below. If you
// *add* this file to your project, you can leave it as is.

/// The list of exceptions that can be thrown by the CLI command handlers
enum MMCliError: Error {

    /// Thrown if there is something wrong with the input parameters for the command
    case invalidParameters

    /// Thrown if there is no result set to work with (and this command depends
    /// on the previous command)
    case missingResultSet

    /// Thrown when the command is not understood
    case unknownCommand

    /// Thrown if the command has yet to be implemented
    /// - Note: You'll need to implement these to get the CLI working properly
    case unimplementedCommand

    case noCommand

    // feel free to add more errors as you need them
}

/// This class representes a set of results. It could be extended to include
/// the command and a history of commands and the results.
class MMResultSet {

    /// The list of files produced by the command
    fileprivate var results: [MMFile]

    /// Constructs a new result set.
    /// - parameter results: the list of files produced by the executed
    /// command, could be empty.
    init(_ results: [MMFile]) {
        self.results = results
    }
    /// Constructs a new result set with an empty list.
    convenience init() {
        self.init([MMFile]())
    }

    /// If there are some results to show, enumerate them and print them out.
    /// - note: this enumeration is used to identify the files in subsequent
    /// commands.
    func show() {
        guard self.results.count > 0 else {
            return
        }
        //swiftlint:disable:next identifier_name
        for (i, file) in self.results.enumerated() {
            print("\(i): \(file)")
        }
    }

    func get(index: Int) throws -> MMFile {
        return self.results[index]
    }

    func result() -> [MMFile] {
        return results
    }
}

/// Generate a friendly prompt and wait for the user to enter a line of input
/// - parameter prompt: The prompt to use
/// - parameter strippingNewline: Strip the newline from the end of the line of
///   input (true by default)
/// - return: The result of `readLine`.
/// - seealso: readLine
func prompt(_ prompt: String, strippingNewline: Bool = true) -> String? {
    // the following terminator specifies *not* to put a newline at the
    // end of the printed line
    print(prompt, terminator: "")
    return readLine(strippingNewline: strippingNewline)
}

/// This protocol specifies the new 'Command' pattern, and is more Object Oriented.
protocol MMCommand {
    var results: MMResultSet? {get}
    func execute() throws
}

// The main difference between this and the previous style is that to use this
// style you first create an instance of the command:
//
//      var command = ListCommand(library, terms)
//
// then you call execute on that instance:
//
//      command.execute()
//
// and finally, the results are stored within the command object:
//
//      command.results?
//
//
// This means that the execute function doesn't need to know about all the
// possible combinations of parameters, libraries, previous result sets. This
// is the problem with the previous implementation. Previously, if *any*
// command needed to have previous result sets, then they *all* needed to know
// about it.

///// Handle unimplemented commands by throwing an exception when trying to
///// execute this command.
//class UnimplementedCommand: MMCommand {
//    var results: MMResultSet?
//    func execute() throws {
//        throw MMCliError.unimplementedCommand
//    }
//}

/// Handle the help command.
class HelpCommand: MMCommand {
    var results: MMResultSet?
    func execute() throws {
        print("""
\thelp                              - this text
\tload <filename> ...               - load file into the collection
\tlist <term> ...                   - list all the files that have the term specified
\tlist                              - list all the files in the collection
\tadd <number> <key> <value> ...    - add some metadata to a file
\tset <number> <key> <value> ...    - this is really a del followed by an add
\tdel <number> <key> ...            - removes a metadata item from a file
\tsave-search <filename>            - saves the last list results to a file
\tsave <filename>                   - saves the whole collection to a file
\tquit                              - exit the program (without prompts)
""")
        // for example:

        // load foo.json bar.json
        //      from the current directory load both foo.json and bar.json and
        //      merge the results

        // list foo bar baz
        //      results in a set of files with metadata containing foo OR bar OR baz

        // add 3 foo bar
        //      using the results of the previous list, add foo=bar to the file
        //      at index 3 in the list

        // add 3 foo bar baz qux
        //      using the results of the previous list, add foo=bar and baz=qux
        //      to the file at index 3 in the list
    }
}

/// Handle the quit command. Exits the program (with exit code 0) without
/// checking if there is anything to save.
class QuitCommand: MMCommand {
    var results: MMResultSet?
    func execute() throws {
        exit(0)
    }
}

class AddMetadataCommand: MMCommand {
    var results: MMResultSet?
    private var params: [String]
    private var collection: Collection
    private var items: [MMFile]

    init(collection: Collection, items: [MMFile], params: [String]) {
        // I don't think we need the collection for this part if we were to
        // use the observer pattern
        self.params = params
        self.items = items
        self.collection = collection
    }

    func execute() throws {
        if params.count < 1 {
            throw MMCliError.invalidParameters
        }

        guard let index = Int(params.remove(at: 0)) else {
            throw MMCliError.invalidParameters
        }

        guard index >= 0 && index < self.items.count else {
            throw MMCliError.invalidParameters
        }

        let file = self.items[index]

        //swiftlint:disable:next todo
        //TODO: pairwise param traversal
        let keyword = params.remove(at: 0)
        let value = params.remove(at: 0)

        collection.add(file: file, keyword: keyword, value: value)
    }
}

class SetMetadataCommand: MMCommand {
    var results: MMResultSet?
    var params: [String]
    private var collection: Collection
    private var items: [MMFile]

    init(collection: Collection, items: [MMFile], params: [String]) {
        // I don't think we need the collection for this part if we were to
        // use the observer pattern
        self.params = params
        self.items = items
        self.collection = collection
    }

    func execute() throws {
        if params.count < 1 {
            throw MMCliError.invalidParameters
        }

        guard let index = Int(params.remove(at: 0)) else {
            throw MMCliError.invalidParameters
        }

        guard index >= 0 && index < self.items.count else {
            throw MMCliError.invalidParameters
        }

        let file = self.items[index]
        //swiftlint:disable:next todo
        //TODO: pairwise param traversal
        let keyword = params.remove(at: 0)
        let value = params.remove(at: 0)

        collection.set(file: file, keyword: keyword, value: value)
    }
}

class DelMetadataCommand: MMCommand {
    var results: MMResultSet?
    var params: [String]
    private var collection: Collection
    private var items: [MMFile]

    init(collection: Collection, items: [MMFile], params: [String]) {
        // I don't think we need the collection for this part if we were to
        // use the observer pattern
        self.params = params
        self.items = items
        self.collection = collection
    }

    func execute() throws {
        if params.count < 1 {
            throw MMCliError.invalidParameters
        }
        guard let index = Int(params.remove(at: 0)) else {
            throw MMCliError.invalidParameters
        }

        guard index >= 0 && index < self.items.count else {
            throw MMCliError.invalidParameters
        }

        let file = self.items[index]

        //swiftlint:disable:next todo
        //TODO: pairwise param traversal
        let keyword = params.remove(at: 0)
        let value = params.remove(at: 0)

        collection.delete(file: file, keyword: keyword, value: value)
    }
}

class LoadCommand: MMCommand {
    var results: MMResultSet?
    private var paths: [String]
    private var collection: Collection

    init(collection: Collection, paths: [String]) {
        self.paths = paths
        self.collection = collection
    }

    func execute() throws {
        for path in self.paths {
            collection.load(filename: path)
        }
    }
}

class ListCommand: MMCommand {
    var results: MMResultSet?
    private var terms: [String]
    private var collection: Collection

    init(collection: Collection, terms: [String]) {
        self.terms = terms
        self.collection = collection
    }

    func execute() throws {
        //swiftlint:disable:next todo
        // TODO: add in other search terms
        // create a dictionary indexed by path and add files to it for each of the terms
        if self.terms.count > 0 {
            self.results = MMResultSet(self.collection.search(term: self.terms[0]))
        } else {
           self.results = MMResultSet(self.collection.all())
        }
    }
}

class SaveCommand: MMCommand {
    var results: MMResultSet?
    private var items: [MMFile]?
    private var collection: Collection
    private var filename: [String]

    init(collection: Collection, filename: [String], items: [MMFile]?) {
        self.items = items
        self.collection = collection
        self.filename = filename
    }

    func execute() throws {
        guard self.filename.count == 1 else {
            throw MMCliError.invalidParameters
        }

        let filename = self.filename[0]
        if let items = self.items {
            self.collection.save(filename: filename, list: items)
        } else {
            self.collection.save(filename: filename)
        }
    }
}
