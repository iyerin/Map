//
//  Region.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/9/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import Foundation

struct Region: Equatable {
    var name: String
    var map: Bool
    var link: String
    var parent: String
    var prefix: String
    
    static func ==(lhs: Region, rhs: Region) -> Bool {
        return (lhs.name == rhs.name && lhs.link == rhs.link)
    }
}
