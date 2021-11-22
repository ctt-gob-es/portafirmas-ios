//
//  SearchUserXMLController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 12/11/21.
//  Copyright © 2021 Izertis. All rights reserved.
//

import Foundation

class SearchUserXMLController: NSObject {

    var parser: XMLParser?
    var dataSource: [User] = []
    var auxUser: User = User()
    var currentElementValue: String = ""

    func parse(data: Data) -> [User] {
        dataSource = []
        self.parser = XMLParser(data: data)
        self.parser?.delegate = self
        self.parser?.parse()
        return dataSource
    }

    func buildRequest(string: String, searchType: SearchType) -> String {
        var type: String
        switch searchType {
        case .authorization:
            type = "autorizados"
        case .validator:
            type = "validadores"
        }
        let mesg = "<rqfinduser mode=\"%s\"><rquserls><![CDATA[\(string)]]></rquserls></rqfinduser>".replacingOccurrences(of: "%s", with: type)
        return mesg
    }
}

extension SearchUserXMLController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "user" {
            auxUser = User()
            if let id = attributeDict["id"] {
                auxUser.id = id
            }
            if let dni = attributeDict["dni"] {
                auxUser.dni = dni
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
        if elementName == "user" {
            auxUser.name = currentElementValue
            dataSource.append(auxUser)
        }
    }
}
