//
//  Metadata.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/// A keyword/value pair representing a metadatum about a file
class Metadata: MMMetadata {

    /// The keyword for the metadatum
    var keyword: String

    /// The value for the metadatum
    var value: String

    /// Create a new instance of a metadatum.
    ///
    /// - Parameters:
    ///   - keyword: The keyword
    ///   - value: The value
    init(keyword: String, value: String) {
        self.keyword = keyword
        self.value = value
    }

    /// Human readable description of this metadatum
    var description: String {
        return "\(self.keyword): \(self.value)"
    }
}
