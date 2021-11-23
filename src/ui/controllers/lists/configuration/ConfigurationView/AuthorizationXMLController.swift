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
    private let authElement: String = "auth"
    private let idElement: String = "id"
    private let typeElement: String = "type"
    private let stateElement: String = "state"
    private let revDateElement: String = "revdate"
    private let sendedElement: String = "sended"
    private let startDateElement: String = "startdate"
    private let userElement: String = "user"
    private let authUserElement: String = "authuser"
    private let observationsElement: String = "observations"

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
            if elementName == authElement {
                auxAuthorization = Authorization()
                if let id = attributeDict[idElement] {
                    auxAuthorization.id = id
                }
                if let type = attributeDict[typeElement] {
                    auxAuthorization.type = AuthorizationType(rawValue: type)
                }
                if let state = attributeDict[stateElement] {
                    auxAuthorization.state = AuthorizationState(rawValue: state)
                }
                if let revDate = attributeDict[revDateElement] {
                    auxAuthorization.endDate = revDate.toDate()?.toString(withFormat: DateFormatConstants.dateTimeFormat) ?? "-"
                }
                if let sended = attributeDict[sendedElement] {
                    auxAuthorization.sended = sended.stringToBool()
                }
                if let startDate = attributeDict[startDateElement] {
                    auxAuthorization.initialDate = startDate.toDate()?.toString(withFormat: DateFormatConstants.dateTimeFormat) ?? "-"
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
        case userElement:
            auxAuthorization.nameSend = currentElementValue
        case authUserElement:
            auxAuthorization.nameReceive = currentElementValue
        case observationsElement:
            auxAuthorization.observations = currentElementValue
        case authElement:
            dataSource.append(auxAuthorization)
        default:
            return
        }
    }
}
