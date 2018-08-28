//
//  Metadata.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 27/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation


class Metadata: MMMetadata{
    var keyword: String
    var value: String
    
    init(keyword: String, value: String){
        self.keyword = keyword
        self.value = value
    }
    
    // I'm using this as a default value -- the empty metadata
    convenience init(){
        self.init(keyword: "", value: "")
    }
    
    var description: String{
        return "\(self.keyword): \(self.value)"
    }
}
