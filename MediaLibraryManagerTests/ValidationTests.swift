//
//  ValidationTests.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 28/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

// the tests we're performing are based around converting from JSON struct to File type
//
// for each file type:
//  1. complete valid data
//  2. missing creator (all files require creator)
//  3. missing other required metadata
//  4. missing optional metadata -- created
//
// a combination of all of the above cases (I want my importer to try its best)

let document = """
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

let image = """
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

let video = """
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

let audio = """
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

var documentFileName = "auto-generated-document-test.json"
var imageFileName = "auto-generated-image-test.json"
var videoFileName = "auto-generated-video-test.json"
var audioFileName = "auto-generated-audio-test.json"

var jsonData: [String:String] = [
    documentFileName: document,
    imageFileName: image,
    videoFileName: video,
    audioFileName: audio,
]

class ValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        for file in jsonData{
            var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            current.appendPathComponent(file.key)
            do {
                try file.value.write(to: current, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                XCTFail("something went wrong removing files ... \(error)")
            }
        }


    }
    
    override func tearDown() {
        for file in jsonData{
            var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            current.appendPathComponent(file.key)
            do{
                try FileManager.default.removeItem(at: current)
            }catch{
                XCTFail("something went wrong removing files ... \(error)")
            }
        }
        
        super.tearDown()
    }
    
    func testDocument() {
        let loader = Importer()
        do{
            _ = try loader.read(filename: documentFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors{
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }
    
    func testImage() {
        let loader = Importer()
        do{
            _ = try loader.read(filename: imageFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors{
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }
    
    func testVideo() {
        let loader = Importer()
        do{
            _ = try loader.read(filename: videoFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors{
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }
    
    func testAudio() {
        let loader = Importer()
        do{
            _ = try loader.read(filename: audioFileName)
        } catch MMImportError.validationFailed(let errors) {
            for cases in errors{
                XCTAssert(cases.key.contains("invalid"))
            }
        } catch {
            XCTFail("Generated an unexpected exception")
        }
    }
}
