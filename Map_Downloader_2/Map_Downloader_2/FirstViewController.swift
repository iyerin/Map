//
//  ViewController.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/8/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

//class Region {
//    var name: String
//    var map: Bool
//    var link: String
//    var regions: [Region]
//
//    init(name: String, map: Bool, link: String, regions: [Region]) {
//        self.name = name
//        self.map = map
//        self.link = link
//        self.regions = regions
//    }
//}

struct Region {
    var name: String
    var map: Bool
    var link: String
    //var regions: [Region]
    var parent: String
}

class FirstViewController: UIViewController, XMLParserDelegate {

    var regions: [Region] = []
    var countryName = String()
    var countryType = String()
    var countryLink = String()
    var countryMap = true
    var regionName = String()
    var regionMap = true
    var regionLink = String()
    var level = 0
    var continent = String()
    var end = true
    var parentName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let regions = myparser()
        for region in regions {
            print (region.name, region.parent)
        }
    }


    func parse_region(attributeDict: [String : String]) {
        countryMap = true
        regionMap = true

        if let name = attributeDict["name"] {
            countryName = name
            if end == true {
                parentName = name
            }
            let first = name.startIndex
            let rest = String(name.dropFirst())
            countryLink = name[first...first].uppercased() + rest
//            if let str = attributeDict["translate"] {
//                if let type = attributeDict["type"] {
//                    if type != "continent" {
//                        var startIndex = str.index(of: "o")!
//                        let stopIndex = str.index(of: ";")!
//                        let upperCase = CharacterSet.uppercaseLetters
//                        for currentCharacter in str.unicodeScalars {
//                            if upperCase.contains(currentCharacter) {
//                                startIndex = str.index(of: Character(currentCharacter))!
//                                break
//                            }
//                        }
//                        countryName = String(str[startIndex..<stopIndex])
//                    }
//                }
//            } else {
//                countryName = countryName.capitalized
//            }
            countryName = countryName.capitalized
        }
        if let type = attributeDict["type"] {
            countryType = type
            if type == "srtm" || type == "hillshade" || type == "continent" {
                countryMap = false
            }
        }
        
        if let mapIs = attributeDict["map"] {
            if mapIs == "no" {
                countryMap = false
            }
        }
        let link = "http://download.osmand.net/download.php?standard=yes&file=" + countryLink + "_europe_2.obf.zip"
        //let region = Region(name: countryName, map: countryMap, link: link, regions: [])
        
        let region = Region(name: countryName, map: countryMap, link: link, parent: parentName)
        regions.append(region)
        end = false
        
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "region" {
            //level += 1
            parse_region(attributeDict: attributeDict)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "region" {
            //level -= 1
            end = true
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

