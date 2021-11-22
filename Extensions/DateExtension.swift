//
//  DateExtension.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 5/11/21.
//

import Foundation

extension Date {
    func toString(withFormat: String = "dd/MM/YYYY") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = withFormat
        return dateFormatter.string(from: self)
    }

    func utcDateToString(withFormat format: String = "dd/MM/YYYY") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let stringdate = dateFormatter.string(from: self)

        return stringdate
    }

    func utcDateToStringTime(withFormat format: String = "HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let stringdate = dateFormatter.string(from: self)

        return stringdate
    }
}
