//
//  Index.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 6/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class Indexer {
    var index: [String: [File]]

    init() {
        index = [:]
    }

    func search(term: String) -> [File]? {
        return index[term]
    }

    func add(files: [File]) {
        for file in files {
            self.add(file: file)
        }
    }

    func add(file: File) {
        for metadata in file.metadata {
            self.add(term: metadata.value, file: file)
        }
    }

    func add(term: String, file: File) {
        if index[term] != nil {
            index[term]?.append(file)
        } else {
            index[term] = [file]
        }
    }

    //swiftlint:disable:next identifier_name
    func remove(term: String, f: File) {
        // this removes the metadata from the index
        index[term] = index[term]?.filter({$0.filename != f.filename})
    }

    // this is the lazy way to do the indexing
    func reindex(files: [File]) {
        self.index.removeAll()
        self.add(files: files)
    }
}
