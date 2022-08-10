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
    private var stateAuthorizationParser = StateAuthorizationXMLController()
    private var authorizationsFlag: Bool = true
    private var isRevokingValidator: Bool = false

    var authorizationsUpdated: (([Authorization]) -> Void)?
    var authorizations: [Authorization] = [] {
        didSet {
            authorizationsUpdated?(authorizations)
        }
    }
    var validatorsUpdated: (([User]) -> Void)?
    var validators: [User] = [] {
        didSet {
            validatorsUpdated?(validators)
        }
    }

    var result: Bool = false {
        didSet {
            if result {
                getValidators()
            }
        }
    }

    var errorMsgUpdated: ((String) -> Void)?
    var errorMsg: String = "" {
        didSet {
            errorMsgUpdated?(errorMsg)
        }
    }

    var areAuthorizationsPending: (() -> Void)?

    func getAuthorizations() {
        authorizationsFlag = true
        authorizations = []
        wsController?.delegate = self
        let data = authorizationParser.buildRequest()
        wsController?.loadPostRequest(withData: data, code: OperationConstants.authorizationList)
        wsController?.startConnection()
    }

    func getValidators() {
        authorizationsFlag = false
        validators = []
        wsController?.delegate = self
        let data = validatorParser.buildRequest()
        wsController?.loadPostRequest(withData: data, code: OperationConstants.validatorList)
        wsController?.startConnection()
    }

    func revokeValidator(id: String) {
        isRevokingValidator = true
        wsController?.delegate = self
        let data = stateAuthorizationParser.buildRevokeValidatorRequest(id: id)
        wsController?.loadPostRequest(withData: data, code: OperationConstants.revokeValidator)
        wsController?.startConnection()
    }

    private func pendingAuthorizations() {
        for item in authorizations {
            if item.state == .pending && !item.sended {
                areAuthorizationsPending?()
                return
            }
        }
    }

    private func cancelWS() {
        wsController?.cancelConnection()
    }
}

extension ConfigurationViewModel: WSDelegate {
    func doParse(_ data: Data!) {
        if isRevokingValidator {
            isRevokingValidator = false
            let response = stateAuthorizationParser.parse(data: data)
            for (key, value) in response {
                result = key
                if !key {
                    errorMsg = value
                }
            }
        } else {
            switch authorizationsFlag {
            case true:
                authorizations = authorizationParser.parse(data: data)
                pendingAuthorizations()
            case false:
                validators = validatorParser.parse(data: data)
            }
        }
    }

    private func didReceiveError(errorString: String) {
        SVProgressHUD.dismiss {
            ErrorService().showAlertView(withTitle: "Alert_View_Error".localized(), andMessage: errorString)
        }
    }
}
