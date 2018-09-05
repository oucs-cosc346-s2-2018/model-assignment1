//
//  Import.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

enum MMImportError: Error {
    case invalidFilePath(filename: String)
    case fileDoesntExist(filename: String)
    case badPermissions(filename: String)
    case validationError(filename: String, errors: [MMValidationError])
    case validationFailed(errors: [String: [MMValidationError]])
}

enum MMExportError: Error {
    case invalidFilePath(filename: String)
}

// This is where a lot of the 'magic' happens. In this enum I'm associating the
// given type of file (as per the JSON data) to a particular class.
//
// Normally in Swift, I don't need to be explict with the values if they
// match the enum cases. However, I want to be able to map from data provided
// by JSON files into something internally.
//
// Why does this belong here? Well, I figure that the IO stuff knows about
// what JSON types we have to deal with it knows about the specifics of
// the format.
// If we were to place this in with the Files, then we're starting to couple
// the JSON type with each of the file's types (again, which is why I'm not
// storing the JSON type in with the file)
//
// If we were to support a new file type (say, 'foo'), then we'd need to add
// a new class and add an entry in here. There's probably a way to
// dynamically generate this enum from a list of classes, but I'm not sure
// it's worth going down that path.
//
// I suppose the other way to do this is to have a dictionary mapping JSON
// data keys to File Types. That way, it could be changed dynamically at
// runtime if needed (but this wasn't in the spec!).
//
enum MMFileType: String, EnumCollection {
    // swiftlint:disable redundant_string_enum_value
    case document = "document"
    case image = "image"
    case audio = "audio"
    case video = "video"
    // swiftlint:enable redundant_string_enum_value

    var dynamic: File.Type {
        switch self {
        case .document:
            return DocumentFile.self
        case .image:
            return ImageFile.self
        case .audio:
            return AudioFile.self
        case .video:
            return VideoFile.self
        }
    }

    static func lookup(file: MMFile) -> String {
        for fileType in MMFileType.cases() where
            type(of: file) == fileType.dynamic {
                return fileType.rawValue
        }
        return "unknown"
    }
}

// There's probably a much better name to give this struct, but given I'm only
// using it in this file and only for import/export I think it's ok...
// swiftlint:disable:next type_name private_over_fileprivate
fileprivate struct F: Codable {
    var fullpath: String
    var fileType: String
    var metadata: [String: String]

    // I need to do this to map from 'fileType' above to the 'type' in the
    // JSON data
    enum CodingKeys: String, CodingKey {
        case fullpath
        case fileType = "type"
        case metadata
    }

    static func fromFile(file: MMFile) -> F {
        //swiftlint:disable:next todo
        //TODO: compose the fullpath from different parts of the file
        var fullpath = file.path

        var fileType: String = MMFileType.lookup(file: file)

        var data: [String: String] {
            var result: [String: String] = [:]
            //swiftlint:disable:next identifier_name
            for m in file.metadata {
                result[m.keyword] = m.value
            }
            return result
        }
        return F(fullpath: fullpath, fileType: fileType, metadata: data)
    }

    //swiftlint:disable:next todo
    //TODO: reduce the length of the function
    func toFile() throws -> File {
        var errors: [MMValidationError] = []
        var metadata: [MMMetadata] = []

        // swiftlint:disable:next identifier_name
        for md in self.metadata {
            metadata.append(Metadata(keyword: md.key, value: md.value))
        }

        // this may look a little weird, but essentially this is doing the
        // following sort of logic:
        //
        // if JSON.type == 'document'
        //      DocumentFile.validator.validate(metadata)
        //      if there are no errors
        //          return DocumentFile(metadata)
        // else if JSON.type == 'image'
        //      ImageFile.validator.validate(metadata)
        //      if there are no errors
        //          return ImageFile(metadata)
        //
        // rinse and repeat for all the different types of file objects we
        // have to deal with.
        //
        if let type = MMFileType.init(rawValue: self.fileType) {
            errors = type.dynamic.validator.validate(data: metadata)
            if errors.count == 0 {
                // here I have to call the initialiser directly. This is
                // usually done by the compiler, but because I've got a
                // variable type I need to be explicit about what's going on.
                return type.dynamic.init(path: self.fullpath,
                                   filename: self.fullpath,
                                   metadata: metadata)
            }
            throw MMImportError.validationError(filename: self.fullpath, errors: errors)
        }
        throw MMValidationError.unknownFileType
    }

    func find(key: String) -> (String, String?) {
        if metadata.contains(where: {$0.key == key}) {
            return (key, metadata[key])
        }
        return (key, nil)
    }
}

// Normally I'm not a huge fan of utility classes, but I don't have another
// place to put it and this is the only place I can use it.
//
// swiftlint:disable:next type_name private_over_fileprivate
fileprivate class IO {
    class func normalisePath(filename: String) throws -> URL {
        let start = filename.index(after: filename.startIndex)
        let end = filename.endIndex

        var result: URL
        switch filename.prefix(1) {
        case "/":
            result = URL(fileURLWithPath: filename)
        case "~":
            result = FileManager.default.homeDirectoryForCurrentUser
            result.appendPathComponent(String(filename[start..<end]))
        case ".":
            result = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            result.appendPathComponent(String(filename[start..<end]))
        default:
            // treat it as if it were in the current working directory
            result = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            result.appendPathComponent(filename)
        }
        return result
    }
}

class Importer: MMFileImport {
    func read(filename: String) throws -> [MMFile] {
        var result: [MMFile] = []
        var errors: [String: [MMValidationError]] = [:]

        let path = try IO.normalisePath(filename: filename)

        // for these various checks, we could have used an approach like we
        // did for file validation. But, I chose not to for the sake
        // as you've already seen an instance of that pattern

        // check file exists
        guard !FileManager.default.fileExists(atPath: path.absoluteString) else {
            throw MMImportError.fileDoesntExist(filename: filename)
        }

        // check permissions
        guard !FileManager.default.isReadableFile(atPath: path.absoluteString) else {
            throw MMImportError.badPermissions(filename: filename)
        }

        let data = try Data(contentsOf: path)
        let decoder = JSONDecoder()
        let media = try decoder.decode([F].self, from: data)

        for file in media {
            do {
                try result.append(file.toFile())
                // swiftlint:disable:next identifier_name
            } catch MMImportError.validationError(let fn, let errs) {
                errors[fn] = errs
            }
        }

        if errors.count > 0 {
            throw MMImportError.validationFailed(errors: errors)
        }
        return result
    }
}

class Exporter: MMFileExport {
    func write(filename: String, items: [MMFile]) throws {
        let path = try IO.normalisePath(filename: filename)
        var output: [F] = []

        //swiftlint:disable:next identifier_name
        for f in items {
            output.append(F.fromFile(file: f))
        }
        let encoder = JSONEncoder()
        let data = try encoder.encode(output)
        try data.write(to: path)
    }
}

// the stuff below is needed to enable me to generate a sequence from an enum.
// apparently it's coming in Swift 4.1, but we're only using 4.0
// 😭
// see: https://stackoverflow.com/questions/32952248/get-all-enum-values-as-an-array
protocol EnumCollection: Hashable {}

extension EnumCollection {
    static func cases() -> AnySequence<Self> {
        //swiftlint:disable:next type_name nesting
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) {
                    $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
}
