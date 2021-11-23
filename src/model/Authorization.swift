//
//  Authorization.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 29/10/21.
//

import Foundation

enum AuthorizationState: String {
    case accepted = "accepted"
    case revoked = "revoked"
    case pending = "pending"
}

struct Authorization {
    var id: String
    var nameSend: String
    var nameReceive: String
    var state: AuthorizationState?
    var sended: Bool
    var type: AuthorizationType?
    var initialDate: String
    var endDate: String
    var observations: String
}

extension Authorization {
    init() {
        id = ""
        nameSend = ""
        nameReceive = ""
        state = nil
        sended = false
        type = nil
        initialDate = ""
        endDate = "-"
        observations = ""
    }

    init(name: String, type: AuthorizationType, initialDate: String, endDate: String, observations: String) {
        id = ""
        self.nameSend = name
        nameReceive = ""
        state = nil
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
