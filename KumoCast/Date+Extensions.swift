//
//  Date+Extensions.swift
//  KumoCast
//
//  Created by Taylor on 7/10/25.
//

import Foundation

extension Date {
    func localDate(for timezone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = timezone
        return dateFormatter.string(from: self)
    }

    func localTime(for timezone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        dateFormatter.timeZone = timezone
        return dateFormatter.string(from: self)
    }

    func localDay(for timezone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        dateFormatter.timeZone = timezone
        return dateFormatter.string(from: self)
    }
}
