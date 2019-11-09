//
//  Parser.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/9/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import Foundation

class Parser: NSObject, XMLParserDelegate {

    var regions: [Region] = []
    var regionName = String()
    var regionMap = Bool()
    var regionLink = String()
    var parentName = String()
    var linkName = String()
    var parentsArray:[String] = [""]
    var regionPrefix = String()
    var level = 0

    func parse_region(attributeDict: [String : String]) {
        regionMap = true
        if let name = attributeDict["name"] {
            regionName = name
            linkName = name
        }
        if let str = attributeDict["translate"] {
            var nameArr = str.split(separator: ";")
            if !nameArr.isEmpty {
                nameArr = nameArr[0].split(separator: "=")
                if nameArr.count == 1 {
                    regionName = String(nameArr[0])
                } else if nameArr.count == 2 {
                    regionName = String(nameArr[1])
                }
            }
        } else {
            regionName = regionName.capitalized
        }
        
        if let prefix = attributeDict["inner_download_prefix"] {
            regionPrefix = prefix == "$name" ? linkName : prefix
        }
        parentsArray[level - 1] = regionName
        parentsArray.append("")
        if level >= 2 {
            parentName = parentsArray[level - 2]
        } else {
            parentName = ""
        }                         ////////////// ------- remove + append
        
        if let type = attributeDict["type"] {
            if type == "srtm" || type == "hillshade" || type == "continent" {
                regionMap = false
            }
        }
        if let mapIs = attributeDict["map"] {
            if mapIs == "no" {
                regionMap = false
            }
        }
        
        if level >= 3 {
            let parent = regions.filter { $0.name == parentName }
            let prefix = parent[0].prefix //////protect
            var mylink = prefix + "_" + linkName
            let first = mylink.startIndex
            let rest = String(mylink.dropFirst())
            mylink = mylink[first...first].uppercased() + rest
            regionLink = "http://download.osmand.net/download.php?standard=yes&file=" + mylink + "_europe_2.obf.zip"
        } else {
            let first = linkName.startIndex
            let rest = String(linkName.dropFirst())
            linkName = linkName[first...first].uppercased() + rest
            regionLink = "http://download.osmand.net/download.php?standard=yes&file=" + linkName + "_europe_2.obf.zip"
        }
        
        let region = Region(name: regionName, map: regionMap, link: regionLink, parent: parentName, prefix: regionPrefix)
        regions.append(region)
        
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "region" {
            level += 1
            parse_region(attributeDict: attributeDict)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "region" {
            level -= 1
        }
    }

    func myparser() -> [Region] {
        if let path = Bundle.main.url(forResource: "regions", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        return(regions)
    }
}
