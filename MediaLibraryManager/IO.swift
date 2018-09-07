//
//  Import.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/// The errors that can be thrown when importing a file.
///
/// - fileDoesntExist: Thrown when the file doesn't exist.
/// - badPermissions: Thrown when there are insufficient permissions.
/// - validationError: Thrown if there is a validation error. This is thrown
///   once per item in the datafile aggregating all the validation errors so far.
/// - validationFailed: Thrown if any of the items in the datafile throw a
///   validation error. We aggregate mutliple item errors into this one.
enum MMImportError: Error {
    case fileDoesntExist(filename: String)
    case badPermissions(filename: String)
    case validationError(filename: String, errors: [MMValidationError])
    case validationFailed(errors: [String: [MMValidationError]])
}

/// The errors that can be thrown when exporting a file.
///
/// - invalidFilePath: If the path to export the data is invalid
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
//
// If we were to place this in with the Files, then we're starting to couple
// the JSON type with each of the file's types (again, which is why I'm not
// storing the JSON type in with the file)
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

    // When adding a new file type, we can add something like the following
    // case to the list above:
    //
    //      case newFile = "novel"
    //
    // which, because Swift is good at complaining, will then force you to
    // specify a following entry in the switch statement below:
    //
    //      case .newFile
    //          return NewFile.self

    /// Mapping between the JSON 'type' and our File classes.
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

    /// Looks up the JSON string 'type' for a given object.
    ///
    /// - Parameter file: The file to lookup
    /// - Returns: a string used to describe the file as a JSON object.
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
/// A struct to describe the JSON data
// swiftlint:disable:next type_name private_over_fileprivate
fileprivate struct F: Codable {

    /// The fullpath of the file (every file in the JSON file has a full path specified)
    var fullpath: String

    /// The type of file (document, or image, or video, or audio)
    var fileType: String

    /// A dictionary of key/value pairs for metadata.
    var metadata: [String: String]

    // I need to do this to map from 'fileType' above to the 'type' in the
    // JSON data

    /// The mapping from the struct's properties into JSON data names.
    /// Generally, they match the names above apart from the 'fileType', which
    /// is so called to avoid shadowing the inbuilt 'type' function.
    ///
    /// - fullpath: the string 'fullpath'
    /// - fileType: the string 'type'
    /// - metadata: the string 'metadata'
    enum CodingKeys: String, CodingKey {
        case fullpath
        case fileType = "type"
        case metadata
    }

    /// Converts an MMFile into one of these structs.
    ///
    /// - Parameter file: The file to convert
    /// - Returns: an 'instance' of the F struct
    static func fromFile(file: MMFile) -> F {
        var fullpath = file.fullpath
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

    /// Creates an appropriate type of file from an 'instance' of this struct
    ///
    /// - Returns: A file instance (one of those specified in the MMFileType enum)
    /// - Throws: A validation error if the data in the JSON file doesn't match the required metadata
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
        // I did start off with an approach like the above. Have a look at
        // the history for this file and you'll see it.
        //
        if let type = MMFileType.init(rawValue: self.fileType) {
            errors = type.dynamic.validator.validate(data: metadata)
            if errors.count == 0 {
                // here I have to call the initialiser directly. This is
                // usually done by the compiler, but because I've got a
                // variable type I need to be explicit about what's going on.

                let url = URL(fileURLWithPath: self.fullpath)
                let path = url.deletingLastPathComponent().relativePath
                let filename = url.lastPathComponent

                return type.dynamic.init(path: path,
                                   filename: filename,
                                   metadata: metadata)
            }
            throw MMImportError.validationError(filename: self.fullpath, errors: errors)
        }
        throw MMValidationError.unknownFileType
    }
}

// Normally I'm not a huge fan of utility classes, but I don't have another
// place to put it and this file is the only place I use it.
//
/// A utility class to contain the path normalisation.
// swiftlint:disable:next type_name private_over_fileprivate
fileprivate class IO {

    /// Normalises a path from an assortment of inputs.
    ///
    /// This will follow the rules below to generate a full path:
    ///
    ///    ~/filename = /Users/<username>/filename
    ///    ./filename = $(CWD)/filename
    ///      filename = $(CWD)/filename
    ///     /path/to/filename = <no change>
    ///
    /// - Parameter filename: The filename to generate the full path for.
    /// - Returns: The fullpath of the filename
    /// - Throws: Any of the URL family of exceptions
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

/// Reads a JSON file and produces a list of MMFile objects
class JSONImporter: MMFileImport {

    /// Reads a JSON file and produces a list of MMFile objects
    ///
    /// - Parameter filename: The (raw) filename to read from
    /// - Returns: A list of MMFile objects
    /// - Throws: if the import failed (see: MMImportError)
    func read(filename: String) throws -> [MMFile] {
        var result: [MMFile] = []
        var errors: [String: [MMValidationError]] = [:]

        let path = try IO.normalisePath(filename: filename)

        // for these various checks, we could have used an approach like we
        // did for file validation. But, I chose not to as you've already
        // seen an instance of that pattern.

        guard !FileManager.default.fileExists(atPath: path.absoluteString) else {
            throw MMImportError.fileDoesntExist(filename: filename)
        }

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

/// Exports a list of MMFiles to JSON data
class JSONExporter: MMFileExport {

    /// Exports a list of MMFiles to JSON data.
    ///
    /// - Parameters:
    ///   - filename: The (raw) filename to write to
    ///   - items: The list of files to write
    /// - Throws: Throws any JSON encoder errors
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

/// Makes the EnumCollection hashable.
//swiftlint:disable:next private_over_fileprivate
fileprivate protocol EnumCollection: Hashable {}

fileprivate extension EnumCollection {
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
