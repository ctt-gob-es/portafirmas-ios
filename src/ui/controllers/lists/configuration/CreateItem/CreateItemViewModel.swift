//
//  CreateItemViewModel.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 12/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation

class CreateItemViewModel: NSObject {
    // MARK: - Properties
    private var type: SearchType
    private let wsController = WSDataController()
    private let searchItemParser = SearchUserXMLController()
    private var stateAuthorizationParser = StateAuthorizationXMLController()
    private var isSearch: Bool = true

    var usersUpdated: (([User]) -> Void)?
    var users: [User] = [] {
        didSet {
            usersUpdated?(users)
        }
    }

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

    // MARK: - Init
    init(type: SearchType) {
        self.type = type
    }

    func searchUser(string: String) {
        isSearch = true
        users = []
        wsController?.delegate = self
        let data = searchItemParser.buildRequest(string: string, searchType: type)
        wsController?.loadPostRequest(withData: data, code: 19)
        wsController?.startConnection()
    }

    func createAuthorization(user: User, authorization: Authorization) {
        isSearch = false
        wsController?.delegate = self
        let data = stateAuthorizationParser.buildCreateAuthorizationRequest(user: user, authorization: authorization)
        wsController?.loadPostRequest(withData: data, code: 25)
        wsController?.startConnection()
    }

    func createValidator(user: User) {
        isSearch = false
        wsController?.delegate = self
        let data = stateAuthorizationParser.buildCreateValidatorRequest(user: user)
        wsController?.loadPostRequest(withData: data, code: 29)
        wsController?.startConnection()
    }
}

extension CreateItemViewModel: WSDelegate {
    func doParse(_ data: Data!) {
        if isSearch {
            let response = searchItemParser.parse(data: data)
            users = response
        } else {
            let response = stateAuthorizationParser.parse(data: data)
            for (key, value) in response {
                result = key
                if !key {
                    errorMsg = value
                }
            }
        }
    }
}
