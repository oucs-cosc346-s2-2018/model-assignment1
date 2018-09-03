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
    case validationError(filename: String, errors: [MMValidationError])
    case validationFailed(errors: [String: [MMValidationError]])
}

var documentValidator = ValidatorSuite(validators: [KeywordValidator(keyword: "creator")])

var imageValidator = ValidatorSuite(validators: [KeywordValidator(keyword: "creator"),
                                            KeywordValidator(keyword: "resolution")])

var videoValidator = ValidatorSuite(validators: [KeywordValidator(keyword: "creator"),
                                            KeywordValidator(keyword: "runtime"),
                                            KeywordValidator(keyword: "resolution")])

var audioValidator = ValidatorSuite(validators: [KeywordValidator(keyword: "creator"),
                                            KeywordValidator(keyword: "runtime")])

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

    static func fromFile(file: MMFile) -> F{
        //TODO compose this of the different parts of the file
        var fullpath = file.path
        
        var type: String {
            // TODO there's gotta be a better way to map from classes to names and vice-versa.
            if file is DocumentFile{
                return "document"
            }
            if file is ImageFile{
                return "image"
            }
            if file is VideoFile{
                return "video"
            }
            if file is AudioFile{
                return "audio"
            }
            return "unknown"
        }
        
        var data: [String: String] {
            var result:[String: String] = [:]
            for m in file.metadata {
                result[m.keyword] = m.value
            }
            return result
        }
        
        return F(fullpath: fullpath, type: type, metadata: data)
        
    }
    
    func toFile() throws -> File{
        var errors: [MMValidationError] = []
        var metadata:[MMMetadata] = []
        for md in self.metadata{
            metadata.append(Metadata(keyword: md.key, value: md.value))
        }
        
        switch(self.type){
        case "document":
            errors = documentValidator.validate(data: metadata)
            if errors.count == 0{
                let creator = metadata.first(where: {$0.keyword == "creator"})!
                return DocumentFile(path: self.fullpath, filename: self.fullpath, metadata: metadata, creator: creator)
            }
        case "image":
            errors = imageValidator.validate(data: metadata)
            if errors.count == 0{
                let creator = metadata.first(where: {$0.keyword == "creator"})!
                let resolution = metadata.first(where: {$0.keyword == "resolution"})!
            
                return ImageFile(path: self.fullpath, filename: self.fullpath, metadata: metadata, creator: creator, resolution: resolution)
            }
        case "video":
            errors = videoValidator.validate(data: metadata)
            if errors.count == 0{
                let creator = metadata.first(where: {$0.keyword == "creator"})!
                let resolution = metadata.first(where: {$0.keyword == "resolution"})!
                let runtime = metadata.first(where: {$0.keyword == "runtime"})!
                return VideoFile(path: self.fullpath, filename: self.fullpath, metadata: metadata, creator: creator, resolution: resolution, runtime: runtime)
            }
        case "audio":
            errors = audioValidator.validate(data: metadata)
            if errors.count == 0{
                let creator = metadata.first(where: {$0.keyword == "creator"})!
                let runtime = metadata.first(where: {$0.keyword == "runtime"})!
                return AudioFile(path: self.fullpath, filename: self.fullpath, metadata: metadata, creator: creator, runtime: runtime)
            }
        default:
            throw MMValidationError.unknownFileType
        }
        throw MMImportError.validationError(filename: self.fullpath, errors: errors)
    }
}

class IO{
    func normalisePath(filename: String) throws -> URL{
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
}

class Importer: IO, MMFileImport{
    func read(filename: String) throws -> [MMFile] {
        var result: [MMFile] = []
        var errors: [String: [MMValidationError]] = [:]
        
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
                } catch MMImportError.validationError(let fn, let errs){
                    errors[fn] = errs
                }
            }
        } catch MMImportError.badPermissions {
            print("bad permissions [\(filename)]")
        } catch MMImportError.fileDoesntExist {
            print("file doesn't exist [\(filename)]")
        } catch MMImportError.invalidFilePath {
            print("invalid file path[\(filename)]")
        }
        
        if errors.count > 0{
            throw MMImportError.validationFailed(errors: errors)
        }
        
        return result
    }
}

class Exporter: IO, MMFileExport{
    func write(filename: String, items: [MMFile]) throws {
        //        do{
        let path = try normalisePath(filename: filename)
        
        var output:[F] = []
        for f in items{
            output.append(F.fromFile(file: f))
        }
        
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(output)
        try data.write(to: path)
        //        } catch {
        //        }
    }
}
