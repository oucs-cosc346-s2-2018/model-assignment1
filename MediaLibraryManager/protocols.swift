//
//  protocols.swift
//  MediaLibraryManager
//  COSC346 S2 2018 Assignment 1
//
//  Created by Paul Crane on 18/06/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

///
/// Make sure you read the task in the README file as that forms the basis of
/// this assignment.
///
/// - important: When you implement these protocols you should not remove
/// anything from this file as our tests depend on this interface (and the
/// following assignment too!)
///
/// - note: You may add your own functions/properties etc. as needed -- we also
/// encourage you to develop your own protocols.

///
/// Represents a file with metadata (a key/value store)
///
/// In this protocol we define three properties and that it must confrom to the
/// CustomStringConvertable protocol (i.e. it also needs to have a description
/// property).
protocol MMFile: CustomStringConvertible {
    var metadata: [MMMetadata] {get set}
    var filename: String {get set}
    var path: String {get set}
}

///
/// Protocol to represent metadata for a media file
///
/// In this protocol we define three properties and that it must confrm to the
/// CustomStringConvertable protocol (i.e. it also needs to have a description
/// property).
///
/// We're using a simple key/value pair as our metadata. For example:
///
///    IMG2018-06-18.png
///    photographer: Paul Crane
///    taken: 2018-06-18 10:14:54
///    location: Dunedin, New Zealand
///
/// When we search for the metadata, we ultimately want to display the files
/// that have that metadata, we're keeping track of the associated file here.
///
protocol MMMetadata: CustomStringConvertible {
    var keyword: String {get set}
    var value: String {get set}
}

/// The main functions of the media metadata collection.
protocol MMCollection: CustomStringConvertible {

    ///
    /// Adds a file's metadata to the media metadata collection.
    ///
    /// - Parameters:
    /// - file: The file and associated metadata to add to the collection
    func add(file: MMFile)

    ///
    /// Adds a specific instance of a metadata to the collection
    ///
    /// - Parameters:
    /// - metadata: The item to add to the collection
    func updateIndex(with metadata: MMMetadata, for file: MMFile)

    ///
    /// Removes a specific instance of a metadata from the collection
    ///
    /// - Parameters:
    /// - metadata: The item to remove from the collection
    func remove(metadata: MMMetadata)

    ///
    /// Finds all the files associated with the keyword
    ///
    /// - Parameters:
    /// - keyword: The keyword to search for
    /// - Returns:
    /// A list of all the metadata associated with the keyword, possibly an
    /// empty list.
    func search(term: String) -> [MMFile]

    ///
    /// Returns a list of all the files in the index
    ///
    /// - Parameters:
    /// - Returns:
    /// A list of all the files in the index, possibly an empty list.
    func all() -> [MMFile]

    ///
    /// Finds all the metadata associated with the keyword of the item
    ///
    /// - Parameters:
    /// - item: The item's keyword to search for.
    /// - Returns:
    /// A list of all the metadata associated with the item's keyword, possibly
    /// an empty list.
    func search(item: MMMetadata) -> [MMFile]
}

///
/// Support importing the media collection from a file (by name)
protocol MMFileImport {
    func read(filename: String) throws -> [MMFile]
}

///
/// Support exporting the media collection to a file (by name)
protocol MMFileExport {
    func write(filename: String, items: [MMFile]) throws
}
