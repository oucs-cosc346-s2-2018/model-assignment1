//
//  SaveTests.swift
//  MediaLibraryManagerTests
//
//  Created by Paul Crane on 3/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class SaveTests: XCTestCase {

    func testSaveSingleFile() {
        let path = "./filename.out"
        let creator = Metadata(keyword: "creator", value: "Paul")
        let document = DocumentFile(path: path,
                                    filename: path,
                                    metadata: [creator],
                                    creator: creator)
        do {
            try JSONExporter().write(filename: "test-export-single-document.json",
                                 items: [document])
            let data = try JSONImporter().read(
                filename: "test-export-single-document.json")
            XCTAssert(data.count == 1)
        } catch {
            print(error)
        }
    }

    func testSaveAllFileTypes() {
        let creator = Metadata(keyword: "creator", value: "Paul")
        let resolution = Metadata(keyword: "resolution", value: "1024x768")
        let runtime = Metadata(keyword: "runtime", value: "3min")

        let documentPath = "./document.out"
        let document = DocumentFile(path: documentPath,
                                    filename: documentPath,
                                    metadata: [creator],
                                    creator: creator)

        let imagePath = "./image.out"
        let image = ImageFile(path: imagePath,
                              filename: imagePath,
                              metadata: [creator, resolution],
                              creator: creator,
                              resolution: resolution)

        let videoPath = "./video.out"
        let video = VideoFile(path: videoPath,
                              filename: videoPath,
                              metadata: [creator, resolution, runtime],
                              creator: creator,
                              resolution: resolution,
                              runtime: runtime)

        let audioPath = "./audio.out"
        let audio = AudioFile(path: audioPath,
                              filename: audioPath,
                              metadata: [creator, runtime],
                              creator: creator,
                              runtime: runtime)

        do {
            try JSONExporter().write(filename: "test-export-multiple-document.json",
                                 items: [document, image, audio, video])

            let data = try JSONImporter().read(
                filename: "test-export-multiple-document.json")

            XCTAssert(data.count == 4)
        } catch {
            print(error)
        }
    }
}
