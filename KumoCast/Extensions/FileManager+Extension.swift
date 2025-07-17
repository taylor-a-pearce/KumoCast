//
//  FileManager+Extension.swift
//  KumoCast
//
//  Created by Taylor on 7/13/25.
//
//import Foundation
//
//extension FileManager {
//    static var fileName = "Cities.json"
//    static var storageURL = URL.documentsDirectory.appendingPathComponent(fileName, conformingTo: .json)
//
//    func fileExists() -> Bool {
//        fileExists(atPath: Self.storageURL.path())
//    }
//
//    func readFile() throws -> Data {
//        do {
//            return try Data(contentsOf: Self.storageURL)
//        } catch {
//            throw error
//        }
//    }
//
//    func saveFile(contents: String) throws {
//        do {
//            try contents.write(to: Self.storageURL, atomically: true, encoding: .utf8)
//        } catch {
//            throw error
//        }
//    }
//}

import Foundation

extension FileManager {

    // Documents directory shortcut
    static var documentsDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // Check whether a file exists
    func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    // Read raw Data
    func readData(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    // Save raw Data atomically
    func saveData(_ data: Data, to url: URL) throws {
        // .atomic writes to a temp file first, then swaps, so you never get half-written JSON
        try data.write(to: url, options: .atomic)
    }
}
