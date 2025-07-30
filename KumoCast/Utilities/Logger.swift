//
//  Logging.swift
//  KumoCast
//
//  Created by Taylor on 7/20/25.
//

import Foundation
import os

private let subsystem = Bundle.main.bundleIdentifier ?? "com.example.KumoCast"

extension Logger {
    static let weather = Logger(subsystem: subsystem, category: "weather")
    static let cache = Logger(subsystem: subsystem, category: "cache")
    static let location = Logger(subsystem: subsystem, category: "location")
    static let search = Logger(subsystem: subsystem, category: "search")

}
