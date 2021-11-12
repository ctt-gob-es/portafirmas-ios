//
//  CreateItemViewModel.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 12/11/21.
//

import Foundation

class CreateItemViewModel: NSObject {
    // MARK: - Properties
    private var type: SearchType
    private let wsController = WSDataController()
    private let searchItemParser = SearchUserXMLController()

    var usersUpdated: (([User]) -> Void)?
    var users: [User] = [] {
        didSet {
            usersUpdated?(users)
        }
    }

    // MARK: - Init
    init(type: SearchType) {
        self.type = type
    }

    func searchUser(string: String) {
        users = []
        wsController?.delegate = self
        let data = searchItemParser.buildRequest(string: string, searchType: type)
        wsController?.loadPostRequest(withData: data, code: 19)
        wsController?.startConnection()
    }
}

extension CreateItemViewModel: WSDelegate {
    func doParse(_ data: Data!) {
        let response = searchItemParser.parse(data: data)
        users = response
    }
}
