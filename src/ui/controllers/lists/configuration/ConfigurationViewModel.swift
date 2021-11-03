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
    var dataSource: [Authorization] = []

    func getAuthorizations() {
        wsController?.delegate = self
        let data = AuthorizationXMLController().buildRequest()
        print(data)
        wsController?.loadPostRequest(withData: data, code: 24)
        wsController?.startConnection()
    }

    private func cancelWS() {
        wsController?.cancelConnection()
    }
}

extension ConfigurationViewModel: WSDelegate {
    func doParse(_ data: Data!) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }

        let parser = AuthorizationXMLController()
        parser.parse(data: data)
        if parser.hasParsed {
            didFinishParsingWithParser(parser: parser)
        } else {
            // error
        }
    }

    private func didFinishParsingWithParser(parser: AuthorizationXMLController) {
//        let finishOK = !parser.finishWithError
//        if !finishOK {
//            let errorCode = parser.errorCode == nil ? kEmptyString : parser.errorCode
//            let err = parser.err == nil ? kEmptyString : parser.err
//            self.didReceiveError(errorString: String(format: "Detail_view_error_messages_from_server".localized(), [err, errorCode]))
//        } else {
//            dataSource = parser.dataSource
//        }
        dataSource = parser.dataSource
    }

    private func didReceiveError(errorString: String) {
        SVProgressHUD.dismiss {
            ErrorService().showAlertView(withTitle: "Alert_View_Error".localized(), andMessage: errorString)
        }
    }
}
