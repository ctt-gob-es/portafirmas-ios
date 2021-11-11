//
//  DateExtension.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 5/11/21.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        return dateFormatter.string(from: self)
    }
}
