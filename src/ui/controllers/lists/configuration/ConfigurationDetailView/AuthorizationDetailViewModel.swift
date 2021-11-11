//
//  AuthorizationDetailViewModel.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 11/11/21.
//

import Foundation

class AuthorizationDetailViewModel: NSObject {
    // MARK: - Properties
    let wsController = WSDataController()
    private var stateAuthorzationParser = StateAuthorizationXMLController()

    var resultUpdated: (() -> Void)?
    var result: Bool = false {
        didSet {
            if result {
                resultUpdated?()
            }
        }
    }

    var errorMsgUpdated: ((String) -> Void)?
    var errorMsg: String = "" {
        didSet {
            errorMsgUpdated?(errorMsg)
        }
    }

    func acceptAuthorization(id: String) {
        startConnection(id: id, code: 27)
    }

    func rejectAuthorization(id: String) {
        startConnection(id: id, code: 26)
    }

    private func startConnection(id: String, code: Int) {
        wsController?.delegate = self
        let data = stateAuthorzationParser.buildRequest(id: id)
        wsController?.loadPostRequest(withData: data, code: code)
        wsController?.startConnection()
    }
}

extension AuthorizationDetailViewModel: WSDelegate {
    func doParse(_ data: Data!) {
        let response = stateAuthorzationParser.parse(data: data)
        for (key, value) in response {
            result = key
            if !key {
                errorMsg = value
            }
        }
    }
}
