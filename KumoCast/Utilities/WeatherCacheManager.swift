//
//  WeatherCacheManager.swift
//  KumoCast
//
//  Created by Taylor on 7/15/25.
//
import Foundation
import CoreLocation
import os

enum WeatherCacheManager {
    private static let filemanager = FileManager.default
    private static let expiry: TimeInterval = 600          // 10 min
    private static let maxDrift: Double      = 50_000       // 50 km

    private static func url(for cityID: UUID) -> URL {
        FileManager.documentsDir.appendingPathComponent(
            "Weather-\(cityID).json",
            conformingTo: .json
        )
    }

    private static let currentURL =
        FileManager.documentsDir.appendingPathComponent("Weather-CurrentLocation.json",
                                                        conformingTo: .json)

    private struct Coordinate: Codable {
        let lat: Double
        let lon: Double
    }


    private struct WeatherPacket: Codable {
        let timestamp: Date
        let coordinate: Coordinate
        let bundle: WeatherBundles
    }

    static func loadCurrent(for location: CLLocation) -> WeatherBundles? {
        guard filemanager.fileExists(at: currentURL),
              let data = try? filemanager.readData(from: currentURL),
              let packet = try? JSONDecoder().decode(WeatherPacket.self, from: data)
        else { return nil }

        let ageCheck   = Date().timeIntervalSince(packet.timestamp) < expiry
        let distanceCheck  = location.distance(from:
                        CLLocation(latitude: packet.coordinate.lat,
                                   longitude: packet.coordinate.lon)) < maxDrift

        return (ageCheck && distanceCheck) ? packet.bundle : nil
    }

    static func saveCurrent(_ bundle: WeatherBundles, location: CLLocation) {
        let packet = WeatherPacket(
            timestamp: Date(),
            coordinate: .init(lat: location.coordinate.latitude,
                              lon: location.coordinate.longitude),
            bundle: bundle)
        if let data = try? JSONEncoder().encode(packet) {
            try? filemanager.saveData(data, to: currentURL)
        }
    }

    // ───────── Saved-city cache ─────────
    static func load(for cityID: UUID) -> WeatherBundles? {
        let url = url(for: cityID)
        guard filemanager.fileExists(at: url),
              let data = try? filemanager.readData(from: url),
              let packet = try? JSONDecoder().decode(WeatherPacket.self, from: data),
              Date().timeIntervalSince(packet.timestamp) < expiry
        else { return nil }
        return packet.bundle
    }

    static func save(_ bundle: WeatherBundles, for cityID: UUID) {
        let packet = WeatherPacket(timestamp: Date(),
                       coordinate: .init(lat: 0, lon: 0),
                       bundle: bundle)
        if let data = try? JSONEncoder().encode(packet) {
            try? filemanager.saveData(data, to: url(for: cityID))
        }
    }


}
