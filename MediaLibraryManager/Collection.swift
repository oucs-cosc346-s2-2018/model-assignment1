//
//  Collection.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 29/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

// we'll do the bare minimum to make this work
class Collection: MMCollection {
    private var importers: [String: MMFileImport]
    private var exporters: [String: MMFileExport]
    private var files: [MMFile]
    private var index: Indexer

    init() {
        files = []
        // this allows us to add additional importers/exporters for
        // different serialisation types
        importers = ["json": Importer()]
        exporters = ["json": Exporter()]
        index = Indexer()
    }

    // brute force reindexing of the library
    func reindex() {
        self.index = Indexer()
        self.index.add(files: self.files)
    }

    // this may need to update the index
    func add(file: MMFile) {
        self.files.append(file)
        self.index.add(file: file)
    }

    // this is part of the index's functionality
    func add(metadata: MMMetadata, file: MMFile) {
        index.add(term: metadata.value, file: file)
    }

    func replace(file: MMFile) {
        // this is done specifically to set the item at that position of the list.
        // if we use a for x in y style loop, then we'd end up just manipulating a copy?
        //swiftlint:disable:next identifier_name
        for i in 0..<self.files.count where self.files[i].filename == file.filename {
            self.files[i] = file
            break
        }
    }

    // this requires both file and index
    func remove(metadata: MMMetadata) {
        if let list = index.search(term: metadata.value) {
            for var file in list {
                if !file.isRequired(metadata: metadata) {
                    index.remove(term: metadata.value, f: file)
                    file.remove(metadata: metadata)
                }
            }
        }
    }

    func search(term: String) -> [MMFile] {
        if let result = index.search(term: term) {
            return result
        }
        return []
    }

    func search(item: MMMetadata) -> [MMFile] {
        // we first reduce the number of files that we need to look through
        let result = self.search(term: item.value)
        // and then we look see if the metadata is contained in the file
        return result.filter({$0.contains(metadata: item)})
    }

    func all() -> [MMFile] {
        return self.files
    }

    var description: String {
        return "Collection contains \(self.files.count) files."
    }

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

    func save(filename: String) {
        self.save(filename: filename, list: self.files)
    }
}
