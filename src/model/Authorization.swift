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
    var type: String
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
        type = ""
        initialDate = ""
        endDate = ""
        observations = ""
    }
}
