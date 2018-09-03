//
//  Collection.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 29/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class Indexer{
    var index:[String: [MMFile]]
    
    init(){
        index = [:]
    }
    
    func search(term:String) -> [MMFile]? {
        return index[term]
    }
    
    func add(term: String, file: MMFile){
        if index[term] != nil {
            index[term]?.append(file)
        }else{
            index[term] = [file]
        }
    }
    func remove(term: String, f: MMFile){
        // this removes the metadata from the index
        index[term] = index[term]?.filter({$0.filename != f.filename})
    }
}

extension MMFile{
    func isRequired(metadata: MMMetadata) -> Bool{
        // I don't like this downcasting, but unless the protocol is
        // modified, I can't think of a way around this.
        if let me = (self as? File){
            if me.requiredMetadata.contains(metadata.keyword){
                return true
            }
        }
        return false
    }
    
    mutating func remove(metadata: MMMetadata){
        self.metadata = self.metadata.filter({$0.keyword != metadata.keyword && $0.value != metadata.value})
    }
}

// we'll do the bare minimum to make this work
class Collection: MMCollection  {
    
    var importers:[String:MMFileImport]
    var exporters:[String:MMFileExport]
    
    var files: [MMFile]
    var index: Indexer
    
    init(){
        files = []
        importers = ["json":Importer()]
        exporters = [:]
        index = Indexer()
    }
    
    // this may need to update the index
    func add(file: MMFile) {
        self.files.append(file)
        for md in file.metadata{
            self.add(metadata: md, file: file)
        }
    }
    
    // this is part of the index's functionality
    func add(metadata: MMMetadata, file: MMFile) {
        index.add(term: metadata.value, file: file)
    }
    
    // this requires both file and index
    func remove(metadata: MMMetadata) {
        if let list = index.search(term: metadata.value){
            for var file in list {
                if !file.isRequired(metadata: metadata){
                    index.remove(term: metadata.value, f: file)
                    file.remove(metadata: metadata)
                }
            }
        }
    }
    
    // this is part of the index
    func search(term: String) -> [MMFile] {
        if let result = index.search(term: term){
            return result
        }
        return []
    }
    
    // this is part of the index
    func search(item: MMMetadata) -> [MMFile] {
        print("that search is not implemented")
        return []
    }
    
    func all() -> [MMFile] {
        return self.files
    }
    
    var description: String{
        return "Collection contains \(self.files.count) files."
    }
    
    // this should work
    func load(filename: String){
        do{
            // find file type of the filename and lookup value in the dictionary
            if let importer = importers["json"]{
                let files = try importer.read(filename: filename)
                for file in files{
                    self.add(file: file)
                }
            }
        } catch where error is MMImportError {
            print(error)
        } catch {
            print("unknown import exception")
        }
    }
    
    func save(filename: String){
        print("not implemented!")
    }
}
