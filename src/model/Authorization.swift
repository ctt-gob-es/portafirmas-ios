//
//  Authorization.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 29/10/21.
//

import Foundation

struct Authorization {
    var id: String
    var name: String
    var state: String
    var sended: Bool
    var type: AuthorizationType?
    var initialDate: String
    var endDate: String
    var observations: String
}

extension Authorization {
    init() {
        id = ""
        name = ""
        state = ""
        sended = false
        type = nil
        initialDate = ""
        endDate = "-"
        observations = ""
    }

    init(name: String, type: AuthorizationType, initialDate: String, endDate: String, observations: String) {
        id = ""
        self.name = name
        state = ""
        sended = true
        self.type = type
        self.initialDate = initialDate
        self.endDate = endDate
        self.observations = observations
    }
}

enum AuthorizationType: String {
    case delegado = "DELEGADO"
    case sustituto = "SUSTITUTO"
}
