//
//  Index.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 6/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

fileprivate extension File {

    /// Gather a list of terms to associate with this file
    ///
    /// - Returns: The list of terms
    func terms() -> [String] {
        var result: [String] = []
        for metadata in self.metadata {
            result.append(metadata.value)
        }
        return result
    }
}

class Indexer {
    var index: [String: [File]]

    /// Creates a new, empty, index
    init() {
        index = [:]
    }

    /// Searches for a term in the index
    ///
    /// - Parameter term: The term to look for
    /// - Returns: A (possibly empty) list of files
    func search(term: String) -> [File] {
        if let result = index[term] {
            return result
        }
        return []
    }

    /// Adds a list of files to the index
    ///
    /// - Parameter files: The files to add to the collection
    func add(files: [File]) {
        for file in files {
            self.add(file: file)
        }
    }

    /// Adds all the terms in the file into the index
    ///
    /// - Parameter file: the file to add to the index
    func add(file: File) {
        for term in file.terms() {
            self.add(term: term, file: file)
        }
    }

    /// Adds a specific term to the index.
    ///
    /// - Parameters:
    ///   - term: The term to add
    ///   - file: The file it's associated with
    func add(term: String, file: File) {
        if index[term] != nil {
            index[term]?.append(file)
        } else {
            index[term] = [file]
        }
    }

    /// Remove a term/file mapping
    ///
    /// - Parameters:
    ///   - term: The term to remove
    ///   - file: The file it was associated with
    func remove(term: String, file: File) {
        index[term] = index[term]?.filter({ !($0 == file) })
    }

    /// Reindex the list of files.
    ///
    /// - Parameter files: The files to add to the index
    func reindex(files: [File]) {
        self.index.removeAll()
        self.add(files: files)
    }
}
