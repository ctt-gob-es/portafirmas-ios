//
//  ConfigurationViewModel.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 25/10/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation

@objc class ConfigurationViewModel: NSObject {
    // MARK: - Properties
    let wsController = WSDataController()
    private var authorizationParser = AuthorizationXMLController()
    private var validatorParser = ValidatorXMLController()
    private var authorizationsFlag: Bool = true

    var authorizationsUpdated: (([Authorization]) -> Void)?
    var authorizations: [Authorization] = [] {
        didSet {
            authorizationsUpdated?(authorizations)
        }
    }
    var validatorsUpdated: (([String]) -> Void)?
    var validators: [String] = [] {
        didSet {
            validatorsUpdated?(validators)
        }
    }

    func getAuthorizations() {
        authorizationsFlag = true
        authorizations = []
        wsController?.delegate = self
        let data = authorizationParser.buildRequest()
        wsController?.loadPostRequest(withData: data, code: 24)
        wsController?.startConnection()
    }

    func getValidators() {
        authorizationsFlag = false
        validators = []
        wsController?.delegate = self
        let data = validatorParser.buildRequest()
        wsController?.loadPostRequest(withData: data, code: 28)
        wsController?.startConnection()
    }

    private func cancelWS() {
        wsController?.cancelConnection()
    }
}

extension ConfigurationViewModel: WSDelegate {
    func doParse(_ data: Data!) {
        switch authorizationsFlag {
        case true:
            authorizations = authorizationParser.parse(data: data)
        case false:
            validators = validatorParser.parse(data: data)
        }
    }

    private func didReceiveError(errorString: String) {
        SVProgressHUD.dismiss {
            ErrorService().showAlertView(withTitle: "Alert_View_Error".localized(), andMessage: errorString)
        }
    }
}
