//
//  StringExtension.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 5/11/21.
//

import Foundation

extension String {

    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dateFormatter.date(from: self) ?? nil
    }

    func stringToBool() -> Bool {
        return self == "true" ? true : false
    }
}
