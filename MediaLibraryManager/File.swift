//
//  File.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

extension MMFile {
    /// The fullpath of the file
    /// This will update the internal path/filename components.
    var fullpath: String {
        get {
            if var result = URL(string: self.path) {
                result.appendPathComponent(self.filename)
                return result.path
            } else {
                return self.path + "/" + self.filename
            }
        }
        set {
            let url = URL(fileURLWithPath: newValue)
            self.path = url.deletingLastPathComponent().relativePath
            self.filename = url.lastPathComponent
        }
    }

    /// Add a keyword:value pair to the file (transforming into a metadata instance)
    ///
    /// - Parameters:
    ///   - keyword: the keyword to use for the metadata
    ///   - value: the value to use for the metadata
    mutating func add(keyword: String, value: String) {
        self.metadata.append(Metadata(keyword: keyword, value: value))
    }

    /// Edit an existing keyword:value pair to the file (transforming into a metadata instance)
    ///
    /// - Parameters:
    ///   - keyword: the keyword to use for the metadata
    ///   - value: the value to use for the metadata
    mutating func edit(keyword: String, value: String) {
        self.delete(keyword: keyword, value: value)
        self.add(keyword: keyword, value: value)
    }

    /// Remove an existing keyword:value pair to the file (transforming into a metadata instance)
    ///
    /// - Parameters:
    ///   - keyword: the keyword to use for the metadata
    ///   - value: the value to use for the metadata
    mutating func delete(keyword: String, value: String) {
        self.metadata = self.metadata.filter({$0.keyword != keyword})
    }
}

extension MMFile {
    /// Two files are equal if their paths are the same
    ///
    /// - Parameters:
    ///   - lhs: the left hand side of the equals operation
    ///   - rhs: the right hand side of the equals operation
    /// - Returns: True iff the two files have the same path
    // we need this as sometimes we compare an MMFile with another MMFile
    static func == (lhs: MMFile, rhs: MMFile) -> Bool {
        return lhs.fullpath == rhs.fullpath
    }
}

/// The object at the root of the File type hierarchy. All file types
/// should extend this one.
class File: MMFile {

    /// The list of metadata associated with the file
    var metadata: [MMMetadata]

    /// The filename of the file. For example, in /path/to/foobar.ext, this is the foorbar.ext part
    var filename: String

    /// The path of the file. For example, in /path/to/foobar.ext, this is the /path/to part
    var path: String

    /// A human-readable string representation of the file
    var description: String {
        return "\(self.filename)"
    }

    /// The default initialiser. Assumed to contain all the metadata of the
    /// file (including all the required metadata.
    ///
    /// - Parameters:
    ///   - path: path of the file in the file system
    ///   - filename: name of the file
    ///   - metadata: the list of metadata associated with the file
    required init(path: String, filename: String, metadata: [MMMetadata]) {
        self.path = path
        self.filename = filename
        self.metadata = metadata
    }

    /// Two files are equal if their paths are the same
    ///
    /// - Parameters:
    ///   - lhs: the left hand side of the equals operation
    ///   - rhs: the right hand side of the equals operation
    /// - Returns: True iff the two files have the same path
    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.fullpath == rhs.fullpath
    }

    /// Two files are equal if their paths are the same
    ///
    /// - Parameters:
    ///   - lhs: the left hand side of the equals operation
    ///   - rhs: the right hand side of the equals operation
    /// - Returns: True iff the two files have the same path
    // we need this as sometimes we compare a File with an MMFile
    static func == (lhs: File, rhs: MMFile) -> Bool {
        return lhs.fullpath == rhs.fullpath
    }

    /// The set of required metadata keys for the particular file
    class var requiredMetadata: Set<String> {
        return Set<String>()
    }

    /// The validators for the files. Creates Keyword Validators
    /// for the items in required metadata.
    class var validator: ValidatorSuite {
        let result = ValidatorSuite()
        for keyword in self.requiredMetadata {
            result.add(validator: KeywordValidator(keyword: keyword))
        }
        return result
    }
}

// I'm going to be lazy and skip the comments for the following classes.
// They're just initialisers that all follow the same sort of pattern:
//
//  TypeFile(path, filename, metadata)
//  TypeFile(path, filename, metadata, required_metadata, ...)
//  TypeFile(path, filename, required_metadata, ...)
//

class DocumentFile: File {
    override class var requiredMetadata: Set<String> {
        return Set<String>(["creator"])
    }

    required init(path: String, filename: String, metadata: [MMMetadata]) {
        super.init(path: path, filename: filename, metadata: metadata)
    }

    convenience init(path: String,
                     filename: String,
                     metadata: [MMMetadata],
                     creator: MMMetadata) {

        // swiftlint:disable:next identifier_name
        var md = metadata
        if !metadata.contains(where: {$0.keyword == creator.keyword}) {
            md.append(creator)
        }
        self.init(path: path,
                  filename: filename,
                  metadata: md)
    }

    convenience init(path: String,
                     filename: String,
                     creator: MMMetadata) {

        self.init(path: path,
                  filename: filename,
                  metadata: [creator],
                  creator: creator)
    }
}

class ImageFile: File {
    override class var requiredMetadata: Set<String> {
        return Set<String>(["creator", "resolution"])
    }

    required init(path: String,
                  filename: String,
                  metadata: [MMMetadata]) {

        super.init(path: path,
                   filename: filename,
                   metadata: metadata)
    }

    convenience init(path: String,
                     filename: String,
                     metadata: [MMMetadata],
                     creator: MMMetadata,
                     resolution: MMMetadata) {

        // swiftlint:disable:next identifier_name
        var md = metadata
        if !metadata.contains(where: {$0.keyword == creator.keyword}) {
            md.append(creator)
        }
        if !metadata.contains(where: {$0.keyword == resolution.keyword}) {
            md.append(resolution)
        }

        self.init(path: path, filename: filename, metadata: md)
    }

    convenience init(path: String, filename: String, creator: MMMetadata, resolution: MMMetadata) {
        self.init(path: path,
                  filename: filename,
                  metadata: [creator, resolution],
                  creator: creator,
                  resolution: resolution)
    }
}

class AudioFile: File {

    override class var requiredMetadata: Set<String> {
        return Set<String>(["creator", "runtime"])
    }

    required init(path: String,
                  filename: String,
                  metadata: [MMMetadata]) {

        super.init(path: path,
                   filename: filename,
                   metadata: metadata)
    }

    convenience init(path: String,
                     filename: String,
                     metadata: [MMMetadata],
                     creator: MMMetadata,
                     runtime: MMMetadata) {

        // swiftlint:disable:next identifier_name
        var md = metadata
        if !metadata.contains(where: {$0.keyword == creator.keyword}) {
            md.append(creator)
        }
        if !metadata.contains(where: {$0.keyword == runtime.keyword}) {
            md.append(runtime)
        }

        self.init(path: path, filename: filename, metadata: md)
    }

    convenience init(path: String,
                     filename: String,
                     creator: MMMetadata,
                     runtime: MMMetadata) {

        self.init(path: path,
                  filename: filename,
                  metadata: [creator, runtime],
                  creator: creator,
                  runtime: runtime)
    }
}

class VideoFile: File {

    override class var requiredMetadata: Set<String> {
        return Set<String>(["creator", "runtime", "resolution"])
    }

    required init(path: String,
                  filename: String,
                  metadata: [MMMetadata]) {

        super.init(path: path,
                   filename: filename,
                   metadata: metadata)
    }

    convenience init(path: String,
                     filename: String,
                     metadata: [MMMetadata],
                     creator: MMMetadata,
                     resolution: MMMetadata,
                     runtime: MMMetadata) {

        // swiftlint:disable:next identifier_name
        var md = metadata
        if !metadata.contains(where: {$0.keyword == creator.keyword}) {
            md.append(creator)
        }
        if !metadata.contains(where: {$0.keyword == resolution.keyword}) {
            md.append(resolution)
        }
        if !metadata.contains(where: {$0.keyword == runtime.keyword}) {
            md.append(runtime)
        }

        self.init(path: path,
                  filename: filename,
                  metadata: md)
    }

    convenience init(path: String,
                     filename: String,
                     creator: MMMetadata,
                     resolution: MMMetadata,
                     runtime: MMMetadata) {

        self.init(path: path,
                  filename: filename,
                  metadata: [creator, resolution, runtime],
                  creator: creator,
                  resolution: resolution,
                  runtime: runtime)
    }
}
