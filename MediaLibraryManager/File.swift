//
//  File.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class File: MMFile{
    var metadata: [MMMetadata]
    var filename: String
    var path: String
    
    var description: String{
        return "\(self.filename)"
    }
    
    init(path: String, filename: String, metadata: [MMMetadata]){
        self.path = path
        self.filename = filename
        self.metadata = metadata
    }
    
    convenience init(path: String, filename: String){
        self.init(path: path, filename: filename, metadata: [])
    }
    
    convenience init(){
        self.init(path: "", filename: "", metadata: [])
    }
}

class DocumentFile: File{
    var creator: MMMetadata
    
    init(path: String, filename: String, metadata: [MMMetadata], creator: MMMetadata){
        self.creator = creator
        super.init(path: path, filename: filename, metadata: metadata)
    }
    
    convenience init(path: String, filename: String, creator: MMMetadata){
        self.init(path: path, filename: filename, metadata: [], creator: creator)
    }
    
    convenience init(creator: MMMetadata){
        self.init(path: "", filename: "", metadata: [], creator: creator)
    }
    
    convenience init(){
        self.init(path: "", filename: "", metadata: [], creator: Metadata())
    }
}

class ImageFile: File{
    var creator: MMMetadata
    var resolution: MMMetadata
    
    init(path: String, filename: String, metadata: [MMMetadata], creator: MMMetadata, resolution: MMMetadata){
        self.creator = creator
        self.resolution = resolution
        super.init(path: path, filename: filename, metadata: metadata)
    }
    
    convenience init(path: String, filename: String, creator: MMMetadata, resolution: MMMetadata){
        self.init(path: path, filename: filename, metadata: [], creator: creator, resolution: resolution)
    }
    
    convenience init(creator: MMMetadata, resolution: MMMetadata){
        self.init(path: "", filename: "", metadata: [], creator: creator, resolution: resolution)
    }
    
    convenience init(){
        self.init(path: "", filename: "", metadata: [], creator: Metadata(), resolution: Metadata())
    }
    
}
class AudioFile: File{
    var creator: MMMetadata
    var runtime: MMMetadata
    
    init(path: String, filename: String, metadata: [MMMetadata], creator: MMMetadata, runtime: MMMetadata){
        self.creator = creator
        self.runtime = runtime
        super.init(path: path, filename: filename, metadata: metadata)
    }
    
    convenience init(path: String, filename: String, creator: MMMetadata, runtime: MMMetadata){
        self.init(path: path, filename: filename, metadata: [], creator: creator, runtime: runtime)
    }
    
    convenience init(creator: MMMetadata, runtime: MMMetadata){
        self.init(path: "", filename: "", metadata: [], creator: creator, runtime: runtime)
    }
    
    convenience init(){
        self.init(path: "", filename: "", metadata: [], creator: Metadata(), runtime: Metadata())
    }
}

class VideoFile: File{
    var creator: MMMetadata
    var runtime: MMMetadata
    var resolution: MMMetadata
    
    init(path: String, filename: String, metadata: [MMMetadata], creator: MMMetadata, resolution: MMMetadata, runtime: MMMetadata){
        self.creator = creator
        self.runtime = runtime
        self.resolution = resolution
        super.init(path: path, filename: filename, metadata: metadata)
    }
    
    convenience init(path: String, filename: String, creator: MMMetadata, resolution: MMMetadata, runtime: MMMetadata){
        self.init(path: path, filename: filename, metadata: [], creator: creator, resolution: resolution, runtime: runtime)
    }
    
    convenience init(creator: MMMetadata, resolution: MMMetadata, runtime: MMMetadata){
        self.init(path: "", filename: "", metadata: [], creator: creator, resolution: resolution, runtime: runtime)
    }
    convenience init(){
        self.init(path: "", filename: "", metadata: [], creator: Metadata(), resolution: Metadata(), runtime: Metadata())
    }
}
