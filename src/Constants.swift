//
//  Constants.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 23/11/21.
//  Copyright © 2021 Izertis. All rights reserved.
//

import Foundation

struct OperationConstants {
    static let userSearch: Int = 19
    static let authorizationList: Int = 24
    static let createAuthorization: Int = 25
    static let revokeAuthorization: Int = 26
    static let acceptAuthorization: Int = 27
    static let validatorList: Int = 28
    static let createValidator: Int = 29
    static let revokeValidator: Int = 30
}

struct DateFormatConstants {
    static let dateFormat = "dd/MM/YYYY"
    static let timeFormat = "HH:mm"
    static let dateTimeFormat = "dd/MM/yyyy HH:mm"
}

struct RequestConstants {
    static let authorizationType = "autorizados"
    static let validatorType = "validadores"
}
