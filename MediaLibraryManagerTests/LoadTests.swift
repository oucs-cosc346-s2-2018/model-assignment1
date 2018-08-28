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
// 4. load invalid JSON
// 5. load a file owned by someone else

class LoadTests: XCTestCase {

    var filename: String = "automatically-generated-test-data.json"
    var alltypesFilename: String = "automatically-generated-test-alltypes.json"
    
    override func setUp() {
        super.setUp()
        
        // we're going to create a new JSON file here as a string to use
        // for testing.
        
        // we'll put it in each of the different places in the filesystem
        // and then load them in the different functions below.
        
        // we'll use a single entry in the JSON document to illustrate that
        // we *can* read data.
        let jsonString: String = "[{\"fullpath\": \"/path/to/foobar.ext\", \"type\": \"document\", \"metadata\": {\"creator\" : \"Paul\"}}]"
        
        let allTypesString: String = "[{\"fullpath\": \"/path/to/document.ext\", \"type\": \"document\", \"metadata\": {\"creator\" : \"Paul\"}},{\"fullpath\": \"/path/to/image.ext\", \"type\": \"image\", \"metadata\": {\"creator\" : \"Paul\"}},{\"fullpath\": \"/path/to/video.ext\", \"type\": \"video\", \"metadata\": {\"creator\" : \"Paul\"}},{\"fullpath\": \"/path/to/audio.ext\", \"type\": \"audio\", \"metadata\": {\"creator\" : \"Paul\"}}]"
        
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
            print("\(error)")
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
            print("something went wrong removing files ... ")
            print("\(error)")
        }
        super.tearDown()
    }

    func testFromFullPath() {
        var current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        current.appendPathComponent(filename)

        let loader = Importer()
        do{
            let result = try loader.read(filename: current.path)
            assert(result.count > 0, "Expected to read *some* data")
        }catch{
            assert(true == false, "Generated un expected exception")
        }
    }
    
    func testFromWorkingDirectory() {
        let loader = Importer()
        do{
            let result = try loader.read(filename: "./" + filename)
            assert(result.count > 0, "Expected to read *some* data")
        }catch{
            assert(true == false, "Generated un expected exception")
        }
    }
    
    func testFromHomeDirectory() {
        let loader = Importer()
        do{
            let result = try loader.read(filename: "~/" + filename)
            assert(result.count > 0, "Expected to read *some* data")
        }catch{
            assert(true == false, "Generated un expected exception")
        }
    }
    
    func testAllFileTypes(){
        let loader = Importer()
        do{
            let result = try loader.read(filename: alltypesFilename)
            
            assert(result.count > 0, "Expected to read *some* data")
            assert(!(result.count < 4), "Too much data")
            assert(!(result.count > 4), "Not enough data")
            
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
                    assert(false, "Unknown file type encountered...")
                }
            }
            
            for count in counts{
                assert(count.value == 1, "too many \(count.key) items")
            }
        }catch{
            assert(true == false, "Generated un expected exception")
        }
    }
}
