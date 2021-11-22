//
//  ValidatorXMLController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 3/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation

class ValidatorXMLController: NSObject {

    var parser: XMLParser?
    var currentElementValue: String = ""
    var dataSource: [String] = []

    func parse(data: Data) -> [String] {
        dataSource = []
        self.parser = XMLParser(data: data)
        self.parser?.delegate = self
        self.parser?.parse()
        return dataSource
    }

    func buildRequest() -> String {
        var mesg: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        mesg.append("<rqt/>")

        return mesg
    }
}

extension ValidatorXMLController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        var newStr = string.replacingOccurrences(of: "\n", with: "")

        newStr = newStr.replacingOccurrences(of: "\t", with: "")
        newStr = newStr.replacingOccurrences(of: "&_lt", with: "<")
        newStr = newStr.replacingOccurrences(of: "&_gt", with: ">")

        if newStr == "\n" { return }
        currentElementValue = newStr
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "user" {
            dataSource.append(currentElementValue)
        }
    }
}
