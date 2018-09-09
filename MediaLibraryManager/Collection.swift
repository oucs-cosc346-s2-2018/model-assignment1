//
//  Collection.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 29/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

extension MMFile {

    /// Test to see if the metadata is associated with this file.
    ///
    /// - Parameter metadata: The item to test
    /// - Returns: true iff the item is part of this file
    func contains(metadata: MMMetadata) -> Bool {
        return self.metadata.contains(where: {
                $0.keyword == metadata.keyword &&
                $0.value == metadata.value
        })
    }

    /// Remove a metadata instance from this file.
    ///
    /// - Parameter metadata: the instance to remove
    mutating func remove(metadata: MMMetadata) {
        self.metadata = self.metadata.filter({
                $0.keyword != metadata.keyword &&
                $0.value != metadata.value
        })
    }
}

/// Collection is composed of the indexer, importer, and exporter and is the main
/// class. If we were to describe it using a design pattern, it's more like
/// a facade, or part of a controller in the MVC pattern
class Collection: MMCollection {
    private var importers: [String: MMFileImport]
    private var exporters: [String: MMFileExport]
    private var files: [File]
    private var index: Indexer

    /// Creates a new (empty) collection
    init() {
        files = []
        // this allows us to add additional importers/exporters for
        // different serialisation types
        importers = ["json": JSONImporter()]
        exporters = ["json": JSONExporter()]
        index = Indexer()
    }

    /// Adds a file to the collection
    ///
    /// - Parameter file: The file to add to the collection
    func add(file: MMFile) {
        //swiftlint:disable:next identifier_name
        if let f = file as? File {
            self.files.append(f)
            self.index.add(file: f)
        }
    }

    /// Updates the index with a specific metadata instance and a given file.
    /// This method *does not* add the metadata to the file.
    ///
    /// - Parameters:
    ///   - metadata: the item to add to the index
    ///   - file: the file to add it to
    func updateIndex(with metadata: MMMetadata, for file: MMFile) {
        //swiftlint:disable:next identifier_name
        if let f = file as? File {
            index.add(term: metadata.value, file: f)
        }
    }

    /// Obliterates a piece of metadata from the entire collection.
    /// This method *does* remove the metadata from the file.
    ///
    /// - Parameter metadata: the metadata to remove from the collection
    func remove(metadata: MMMetadata) {
        let list = index.search(term: metadata.value)
        for var file in list {
            let data = file.metadata.filter({$0.keyword != metadata.keyword})
            if type(of: file).validator.validate(data: data).count == 0 {
                index.remove(term: metadata.value, file: file)
                file.remove(metadata: metadata)
            }
        }
    }

    /// Find a given term in the collection's metadata
    ///
    /// - Parameter term: The needle to look for.
    /// - Returns: A (possibly empty) list of files where the metadata contains that term
    func search(term: String) -> [MMFile] {
        return index.search(term: term)
    }

    /// Finds the files with a given metadata value (and not keyword).
    ///
    /// - Parameter item: The value (as a metadata instance) to look for
    /// - Returns: a (possibly empty) list of files that have the value
    func search(item: MMMetadata) -> [MMFile] {
        // we first reduce the number of files that we need to look through
        let result = self.search(term: item.value)
        // and then we look see if the metadata is contained in the file
        return result.filter({$0.contains(metadata: item)})
    }

    /// Accessor for the list of files in the collection.
    ///
    /// - Returns: a list of all the files in the collection
    func all() -> [MMFile] {
        return self.files
    }

    /// A string representation of the collection (a string containing the
    /// number of items).
    var description: String {
        return "Collection contains \(self.files.count) files."
    }

    /// Read a file and import the items contained within.
    /// At present, it'll only read from JSON files (we only have a JSON
    /// importer at the moment), but it would be (relatively) trivial to add other
    /// serialisations at a later date.
    ///
    /// - Parameter filename: The file to read from.
    func load(filename: String) {
        do {
            if let importer = importers["json"] {
                let files = try importer.read(filename: filename)
                for file in files {
                    self.add(file: file)
                }
            }
        } catch where error is MMImportError {
            print(error)
        } catch {
            print("unknown import exception")
        }
    }

    /// Writes a list of metadata to the given file.
    /// At present, it'll only write to JSON files (we only have a JSON
    /// exporter at the moment), but it would be (relatively) trivial to add other
    /// serialisations at a later date.
    ///
    /// - Parameters:
    ///   - filename: The filename to write to.
    ///   - list: The list of files to write.
    func save(filename: String, list: [MMFile]) {
        do {
            if let exporter = exporters["json"] {
                try exporter.write(filename: filename, items: list)
            }
        } catch where error is MMExportError {
            print(error)
        } catch {
            print("unknown export exception")
        }
    }

    /// Write the entire collection to a file.
    ///
    /// - Parameter filename: The filename to write to.
    func save(filename: String) {
        self.save(filename: filename, list: self.files)
    }

    /// Remove a piece of metadata associated with the given file.
    ///
    /// - Parameters:
    ///   - file: The file to remove the data from
    ///   - keyword: The metadata's keyword
    ///   - value: The metadata's value
    func delete(file: MMFile, keyword: String, value: String) {
        //swiftlint:disable:next identifier_name
        for var f in self.files where f == file {
            f.delete(keyword: keyword, value: value)
        }
        //swiftlint:disable:next todo
        //TODO: this is inefficient and should be observed by the indexer
        index.reindex(files: self.files)
    }

    /// Change a piece of metadata associated with the given file.
    ///
    /// - Parameters:
    ///   - file: The file to remove the data from
    ///   - keyword: The metadata's keyword
    ///   - value: The metadata's value
    func set(file: MMFile, keyword: String, value: String) {
        //swiftlint:disable:next identifier_name
        for var f in self.files where f == file {
            f.edit(keyword: keyword, value: value)
        }

        //swiftlint:disable:next todo
        //TODO: this is inefficient
        index.reindex(files: self.files)
    }

    /// Add a piece of metadata to the given file.
    ///
    /// - Parameters:
    ///   - file: The file to remove the data from
    ///   - keyword: The metadata's keyword
    ///   - value: The metadata's value
    func add(file: MMFile, keyword: String, value: String) {
        //swiftlint:disable:next identifier_name
        for var f in self.files where f == file {
            f.add(keyword: keyword, value: value)
        }

        //swiftlint:disable:next todo
        //TODO: this is inefficient and should be observed by the indexer
        index.reindex(files: self.files)
    }
}
