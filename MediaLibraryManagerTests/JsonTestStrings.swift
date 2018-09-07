//
//  JsonTestStrings.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 29/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

let singleDocumentValid: String = """
[
    {
        "fullpath": "/path/to/foobar.ext",
        "type": "document",
        "metadata": {
            "creator" : "Paul"
        }
    }
]
"""

let allTypesValid: String = """
[
    {
        "fullpath": "/path/to/document.ext",
        "type": "document",
        "metadata": {
            "creator" : "Paul"
        }
    },{
        "fullpath": "/path/to/image.ext",
        "type": "image",
        "metadata": {
            "creator" : "Paul",
            "resolution": "1024x768"
        }
    },{
        "fullpath": "/path/to/video.ext",
        "type": "video",
        "metadata": {
            "creator" : "Paul",
            "resolution": "1024x768",
            "runtime": "3mins"
        }
    },{
        "fullpath": "/path/to/audio.ext",
        "type": "audio",
        "metadata": {
            "creator" : "Paul",
            "runtime": "3mins"
        }
    }
]
"""

let documentValidAndInvalid = """
[
    {
        "fullpath": "/path/to/valid.ext",
        "type": "document",
        "metadata": {
            "creator" : "Paul"
        }
    },{
        "fullpath": "/path/to/invalid-no-creator.ext",
        "type": "document",
        "metadata": {}
    }
]
"""

let imageValidAndInvalid = """
[
    {
        "fullpath": "/path/to/valid.ext",
        "type": "image",
        "metadata": {
            "creator" : "Paul",
            "resolution": "1024x768"
        }
    },{
        "fullpath": "/path/to/invalid-no-creator.ext",
        "type": "image",
        "metadata": {
            "resolution": "1024x768"
        }
    },{
        "fullpath": "/path/to/invalid-no-resolution.ext",
        "type": "image",
        "metadata": {
            "creator": "Paul"
        }
    },{
        "fullpath": "/path/to/invalid-no-metadata.ext",
        "type": "image",
        "metadata": {}
    }
]
"""

let videoValidAndInvalid = """
[
    {
        "fullpath": "/path/to/valid.ext",
        "type": "video",
        "metadata": {
            "creator" : "Paul",
            "resolution": "1024x768",
            "runtime": "3min"
        }
    },{
        "fullpath": "/path/to/invalid-no-creator.ext",
        "type": "video",
        "metadata": {
            "resolution": "1024x768",
            "runtime": "3min"
        }
    },{
        "fullpath": "/path/to/invalid-no-resolution.ext",
        "type": "video",
        "metadata": {
            "creator": "Paul",
            "runtime": "3min"
        }
    },{
        "fullpath": "/path/to/invalid-no-runtime.ext",
        "type": "video",
        "metadata": {
            "creator": "Paul",
            "resolution": "1024x768",
        }
    },{
        "fullpath": "/path/to/invalid-no-runtime-no-resolution.ext",
        "type": "video",
        "metadata": {
            "creator": "Paul",
        }
    },{
        "fullpath": "/path/to/invalid-no-metadata.ext",
        "type": "video",
        "metadata": {}
    }
]
"""

let audioValidAndInvalid = """
[
    {
        "fullpath": "/path/to/valid.ext",
        "type": "audio",
        "metadata": {
            "creator" : "Paul",
            "runtime": "3min"
        }
    },{
        "fullpath": "/path/to/invalid-no-creator.ext",
        "type": "audio",
        "metadata": {
            "runtime": "3min"
        }
    },{
        "fullpath": "/path/to/invalid-no-runtime.ext",
        "type": "audio",
        "metadata": {
            "creator": "Paul",
        }
    },{
        "fullpath": "/path/to/invalid-no-metadata.ext",
        "type": "audio",
        "metadata": {}
    }
]
"""

var singleDocumentValidfilename = "auto-generated-single-document-test.json"
var allTypesValidfilename = "auto-generated-all-types-test.json"
var documentValidAndInvalidFileName = "auto-generated-document-test.json"
var imageValidAndInvalidFileName = "auto-generated-image-test.json"
var videoValidAndInvalidFileName = "auto-generated-video-test.json"
var audioValidAndInvalidFileName = "auto-generated-audio-test.json"

var filenameDataMapping: [String: String] = [
    singleDocumentValidfilename: singleDocumentValid,
    allTypesValidfilename: allTypesValid,
    documentValidAndInvalidFileName: documentValidAndInvalid,
    imageValidAndInvalidFileName: imageValidAndInvalid,
    videoValidAndInvalidFileName: videoValidAndInvalid,
    audioValidAndInvalidFileName: audioValidAndInvalid
]

func writeAllToCurrentDirectory() throws {
    for file in filenameDataMapping {
        var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        current.appendPathComponent(file.key)
        try file.value.write(to: current, atomically: true, encoding: String.Encoding.utf8)
    }
}

func removeAllFromCurrentDirectory() throws {
    for file in filenameDataMapping {
        var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        current.appendPathComponent(file.key)
        try FileManager.default.removeItem(at: current)
    }
}
