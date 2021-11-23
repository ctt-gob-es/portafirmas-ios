//
//  StateAuthorizationXMLController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 11/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation

class StateAuthorizationXMLController: NSObject {

    var parser: XMLParser?
    var currentElementValue: String = ""
    var dataSource: [Bool : String] = [:]
    var isError: Bool = false
    var auxResult: String = ""
    var errorMsg: String = ""
    private let resultElement: String = "result"
    private let errorElement: String = "errorMsg"

    func parse(data: Data) -> [Bool : String] {
        self.parser = XMLParser(data: data)
        self.parser?.delegate = self
        self.parser?.parse()
        return dataSource
    }

    func buildRequest(id: String) -> String {
        "<rquserauth id=\"" + id + "\"/>"
    }

    func buildCreateAuthorizationRequest(user: User, authorization: Authorization) -> String {
        "<rqsaveauth type=\"\(authorization.type?.rawValue ?? "")\"><authuser id=\"\(user.id)\" dni=\"012340000\">\(authorization.nameSend)</authuser> <startdate>\(authorization.initialDate)</startdate> <expdate>\(authorization.endDate)</expdate><observations>\(authorization.observations)</observations></rqsaveauth>"
    }

    func buildCreateValidatorRequest(user: User) -> String {
        "<rqsavevalid><validator id=\"\(user.id)\" dni=\"\(user.dni)\">\(user.name)</validator></rqsavevalid>"
    }

    func buildRevokeValidatorRequest(id: String) -> String {
        "<rqrevvalidator id=\"\(id)\"/>"
    }
}

extension StateAuthorizationXMLController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == errorElement {
            isError = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        var newStr = string.replacingOccurrences(of: "\n", with: "")

        newStr = newStr.replacingOccurrences(of: "\t", with: "")
        newStr = newStr.replacingOccurrences(of: "&_lt", with: "<")
        newStr = newStr.replacingOccurrences(of: "&_gt", with: ">")
        if newStr == "\n" { return }

        if !currentElementValue.isEmpty {
            currentElementValue.append(newStr)
        } else {
            currentElementValue = newStr
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == resultElement {
            if isError {
                auxResult = currentElementValue
            } else {
                dataSource = [currentElementValue.stringToBool() : ""]
            }
        }
        if elementName == errorElement {
            dataSource = [auxResult.stringToBool() : currentElementValue]
        }

        currentElementValue = ""
    }
}
