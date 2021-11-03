//
//  AuthorizationXMLController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 27/10/21.
//

import Foundation

class AuthorizationXMLController: NSObject {

    var parser: XMLParser?
    var currentElementValue: String = ""
    var dataSource: [Authorization] = []
    var auxAuthorization = Authorization()
    var hasParsed: Bool = false

    func parse(data: Data) -> [Authorization] {
        self.parser = XMLParser(data: data)
        self.parser?.delegate = self
        self.hasParsed = ((parser?.parse()) != nil)
        return dataSource
    }


    func buildRequest() -> String {
        var mesg: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        mesg.append("<rqt/>")

        return mesg
    }
}

extension AuthorizationXMLController: XMLParserDelegate {
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            if elementName == "auth" {
                auxAuthorization = Authorization()
            }
        }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        var newStr = string.replacingOccurrences(of: "\n", with: "")

        newStr = newStr.replacingOccurrences(of: "\t", with: "")
        newStr = newStr.replacingOccurrences(of: "&_lt", with: "<")
        newStr = newStr.replacingOccurrences(of: "&_gt", with: ">")

        if newStr == "\n" { return }

        if currentElementValue.isEmpty {
            currentElementValue = newStr
        } else {
            currentElementValue.append(contentsOf: newStr)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "user":
            auxAuthorization.name = currentElementValue
        case "type":
            auxAuthorization.type = currentElementValue
        case "state":
            auxAuthorization.state = currentElementValue
        case "startDate":
            auxAuthorization.initialDate = currentElementValue
        case "revDate":
            auxAuthorization.endDate = currentElementValue
        case "sended":
            auxAuthorization.sended = stringToBool(element: currentElementValue)
        case "observations":
            auxAuthorization.observations = currentElementValue
        case "auth":
            dataSource.append(auxAuthorization)
        default:
            return
        }
    }

    private func stringToBool(element: String) -> Bool {
        return element == "true" ? true : false
    }
}
