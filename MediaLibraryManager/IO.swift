//
//  Import.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

enum MMImportError: Error{
    case invalidFilePath
    case fileDoesntExist
    case badPermissions
    case unknownFileType
}

enum MMValidationError: Error{
    case missingCreator
}

struct F: Codable{
    var fullpath: String
    var type: String
    var metadata: [String: String]
    
    func find(key: String) -> (String, String?){
        if metadata.contains(where: {$0.key == key}){
            return (key, metadata[key])
        }
        return (key, nil)
    }
    
    
    func toFile() throws -> File{
        // this doesn't handle validation particularly well
        // we're using the above constructor for *all* the instances
        // we don't yet do any validation
        
        // ideally we should do something like this:
        // var file = try DocumentFile.validate(data: data)
        
        switch(self.type){
        case "document":
            return DocumentFile(data: self)
        case "image":
            return ImageFile(data: self)
        case "video":
            return VideoFile(data: self)
        case "audio":
            return AudioFile(data: self)
        default:
            throw MMImportError.unknownFileType
        }
    }
}

// I'm placing this here so we don't pollute the File with the
// JSON representation stuff as that's dependent on the file structure
// (and this importing logic).

// I also think that this would be better as a factory and creating the
// specific instances of the classes...

extension DocumentFile{
    convenience init(data: F){
        self.init()
        
        self.filename = data.fullpath
        self.path = data.fullpath
        self.metadata = []
        
        for md in data.metadata{
            self.metadata.append(Metadata(keyword: md.key, value: md.value))
        }
    }
}

extension ImageFile{
    convenience init(data: F){
        self.init()
        
        self.filename = data.fullpath
        self.path = data.fullpath
        self.metadata = []
        
        for md in data.metadata{
            self.metadata.append(Metadata(keyword: md.key, value: md.value))
        }
    }
}

extension VideoFile{
    convenience init(data: F){
        self.init()
        
        self.filename = data.fullpath
        self.path = data.fullpath
        self.metadata = []
        
        for md in data.metadata{
            self.metadata.append(Metadata(keyword: md.key, value: md.value))
        }
    }
}

extension AudioFile{
    convenience init(data: F){
        self.init()
        
        self.filename = data.fullpath
        self.path = data.fullpath
        self.metadata = []
        
        for md in data.metadata{
            self.metadata.append(Metadata(keyword: md.key, value: md.value))
        }
    }
}

class Importer: MMFileImport{
    
    private func normalisePath(filename: String) throws -> URL{
        let start = filename.index(after: filename.startIndex)
        let end = filename.endIndex
        
        var result: URL
        switch(filename.prefix(1)){
        case "/":
            result = URL(fileURLWithPath: filename)
        case "~":
            result = FileManager.default.homeDirectoryForCurrentUser
            result.appendPathComponent(String(filename[start..<end]))
        case ".":
            result = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            result.appendPathComponent(String(filename[start..<end]))
        default:
            // try treat it as if it were in the current working directory
            result = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            result.appendPathComponent(filename)
        }
        return result
    }
    
    func read(filename: String) throws -> [MMFile] {
        var result: [MMFile] = []
        do{
            let path = try normalisePath(filename: filename)
            // check file exists
            guard !FileManager.default.fileExists(atPath: path.absoluteString) else {
                throw MMImportError.fileDoesntExist
            }
            
            // check permissions
            guard !FileManager.default.isReadableFile(atPath: path.absoluteString) else {
                throw MMImportError.badPermissions
            }
            
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            let media = try decoder.decode([F].self, from: data)
            
            for file in media{
                do{
                    try result.append(file.toFile())
                } catch MMImportError.unknownFileType {
                    print("unknown file type \"\(file.type)]\"")
                }
            }
        } catch MMImportError.badPermissions {
            print("bad permissions [\(filename)]")
        } catch MMImportError.fileDoesntExist {
            print("file doesn't exist [\(filename)]")
        } catch MMImportError.invalidFilePath {
            print("invalid file path[\(filename)]")
        } catch {
            print("Something went wrong with creating the paths...")
            print("\(error)")
        }
        return result
    }
}
