//
//  AuthorizationXMLController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 27/10/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation

class AuthorizationXMLController: NSObject {

    var parser: XMLParser?
    var currentElementValue: String = ""
    var dataSource: [Authorization] = []
    var auxAuthorization = Authorization()

    func parse(data: Data) -> [Authorization] {
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

extension AuthorizationXMLController: XMLParserDelegate {
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            if elementName == "auth" {
                auxAuthorization = Authorization()
                if let id = attributeDict["id"] {
                    auxAuthorization.id = id
                }
                if let type = attributeDict["type"] {
                    auxAuthorization.type = AuthorizationType(rawValue: type)
                }
                if let state = attributeDict["state"] {
                    auxAuthorization.state = state
                }
                if let revDate = attributeDict["revdate"] {
                    auxAuthorization.endDate = revDate.toDate()?.toString(withFormat: "dd/MM/yyyy HH:mm") ?? "-"
                }
                if let sended = attributeDict["sended"] {
                    auxAuthorization.sended = sended.stringToBool()
                }
                if let startDate = attributeDict["startdate"] {
                    auxAuthorization.initialDate = startDate.toDate()?.toString(withFormat: "dd/MM/yyyy HH:mm") ?? "-"
                }
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
        switch elementName {
        case "user":
            auxAuthorization.name = currentElementValue
        case "observations":
            auxAuthorization.observations = currentElementValue
        case "auth":
            dataSource.append(auxAuthorization)
        default:
            return
        }
    }
}
