//
//  Index.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 6/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class Indexer {
    var index: [String: [MMFile]]
    
    init() {
        index = [:]
    }
    
    func search(term: String) -> [MMFile]? {
        return index[term]
    }
    
    func add(files: [MMFile]) {
        for file in files {
            self.add(file: file)
        }
    }
    
    func add(file: MMFile) {
        //swiftlint:disable:next identifier_name
        for md in file.metadata {
            self.add(term: md.value, file: file)
        }
    }
    
    func add(term: String, file: MMFile) {
        if index[term] != nil {
            index[term]?.append(file)
        } else {
            index[term] = [file]
        }
    }
    
    //swiftlint:disable:next identifier_name
    func remove(term: String, f: MMFile) {
        // this removes the metadata from the index
        index[term] = index[term]?.filter({$0.filename != f.filename})
    }
}

extension MMFile {
    func isRequired(metadata: MMMetadata) -> Bool {
        // I don't like this downcasting, but unless the protocol is
        // modified, I can't think of a way around this.
        //swiftlint:disable:next identifier_name
        if let me = (self as? File) {
            if type(of: me).requiredMetadata.contains(metadata.keyword) {
                return true
            }
        }
        return false
    }
    
    func contains(metadata: MMMetadata) -> Bool {
        //swiftlint:disable:next identifier_name
        for md in self.metadata {
            //swiftlint:disable:next todo
            //TODO: make metadata equatable
            if md.keyword == metadata.keyword && md.value == metadata.value {
                return true
            }
        }
        return false
    }
    
    mutating func remove(metadata: MMMetadata) {
        self.metadata = self.metadata.filter({$0.keyword != metadata.keyword && $0.value != metadata.value})
    }
}
