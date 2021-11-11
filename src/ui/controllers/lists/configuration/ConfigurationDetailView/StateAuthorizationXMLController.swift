//
//  StateAuthorizationXMLController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 11/11/21.
//

import Foundation

class StateAuthorizationXMLController: NSObject {

    var parser: XMLParser?
    var currentElementValue: String = ""
    var dataSource: [Bool : String] = [:]
    var isError: Bool = false
    var auxResult: String = ""
    var errorMsg: String = ""

    func parse(data: Data) -> [Bool : String] {
        self.parser = XMLParser(data: data)
        self.parser?.delegate = self
        self.parser?.parse()
        return dataSource
    }

    func buildRequest(id: String) -> String {
        let mesg: String = "<rquserauth id=\"" + id + "\"/>"
        return mesg
    }
}

extension StateAuthorizationXMLController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "errorMsg" {
            isError = true
        }
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
        if elementName == "result" {
            if isError {
                auxResult = currentElementValue
            } else {
                dataSource = [currentElementValue.stringToBool() : ""]
            }
        }
        if elementName == "errorMsg" {
            dataSource = [auxResult.stringToBool() : currentElementValue]
        }
    }
}
