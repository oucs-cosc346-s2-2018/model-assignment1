//
//  FullPathLoadTest.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

// the tests we're performing are:
//
// 1. load a valid JSON from a full path
// 2. load a valid JSON from the current working directory
// 3. load a valid JSON from the user's home directory

// some other tests that should be performed:
//
// 4. load invalid JSON (to make sure the importer is handling things properly)
// 5. load a file owned by someone else

class LoadTests: XCTestCase {

    var filename: String = "automatically-generated-test-data.json"
    var alltypesFilename: String = "automatically-generated-test-alltypes.json"
    
    override func setUp() {
        super.setUp()
        
        let jsonString: String = """
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
        
        let allTypesString: String = """
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
        var home = FileManager.default.homeDirectoryForCurrentUser
        home.appendPathComponent(filename)
        
        var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        current.appendPathComponent(filename)
        
        var alltypes = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        alltypes.appendPathComponent(alltypesFilename)
        
        do {
            try jsonString.write(to: home, atomically: true, encoding: String.Encoding.utf8)
            try jsonString.write(to: current, atomically: true, encoding: String.Encoding.utf8)
            try allTypesString.write(to: alltypes, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            XCTFail("something went wrong writing files ... \(error)")
        }
    }
    
    override func tearDown() {
        
        var home = FileManager.default.homeDirectoryForCurrentUser
        home.appendPathComponent(filename)
        
        var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        current.appendPathComponent(filename)
        
        var alltypes = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        alltypes.appendPathComponent(alltypesFilename)
        
        do{
            try FileManager.default.removeItem(at: home)
            try FileManager.default.removeItem(at: current)
            try FileManager.default.removeItem(at: alltypes)
        }catch{
            XCTFail("something went wrong removing files ... \(error)")
        }
        super.tearDown()
    }

    func testFromFullPath() {
        var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        current.appendPathComponent(filename)

        let loader = Importer()
        do{
            let result = try loader.read(filename: current.path)
            XCTAssert(result.count > 0, "Expected to read *some* data")
        }catch{
            XCTFail("Generated un expected exception")
        }
    }
    
    func testFromWorkingDirectory() {
        let loader = Importer()
        do{
            let result = try loader.read(filename: "./" + filename)
            XCTAssert(result.count > 0, "Expected to read *some* data")
        }catch{
            XCTFail("Generated un expected exception")
        }
    }
    
    func testFromHomeDirectory() {
        let loader = Importer()
        do{
            let result = try loader.read(filename: "~/" + filename)
            XCTAssert(result.count > 0, "Expected to read *some* data")
        }catch{
            XCTFail("Generated un expected exception")
        }
    }
    
    func testAllFileTypes(){
        let loader = Importer()
        do{
            let result = try loader.read(filename: alltypesFilename)
            
            XCTAssert(result.count > 0, "Expected to read *some* data")
            XCTAssert(!(result.count < 4), "Too much data")
            XCTAssert(!(result.count > 4), "Not enough data")
            
            var counts: [String : Int] = ["document": 0,
                                          "image": 0,
                                          "video": 0,
                                          "audio": 0]
            for file in result{
                switch(type(of: file)){
                case is DocumentFile.Type:
                    counts["document"]? += 1
                case is ImageFile.Type:
                    counts["image"]? += 1
                case is VideoFile.Type:
                    counts["video"]? += 1
                case is AudioFile.Type:
                    counts["audio"]? += 1
                default:
                    XCTFail("Unknown file type encountered...")
                }
            }
            
            for count in counts{
                XCTAssert(count.value == 1, "too many \(count.key) items")
            }
            
        }catch{
            XCTFail("Generated un expected exception")
        }
    }
}
