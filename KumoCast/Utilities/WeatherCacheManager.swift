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

    static func loadCachedWeatherForCurrentLocation(from location: CLLocation) -> WeatherBundles? {
        guard filemanager.fileExists(at: currentURL) else {
            Logger.cache.debug("No current location weather cache found.")
            return nil
        }

        do {
            let data = try filemanager.readData(from: currentURL)
            let packet = try JSONDecoder().decode(WeatherPacket.self, from: data)

            let ageCheck = Date().timeIntervalSince(packet.timestamp) < expiry
            if !ageCheck {
                Logger.cache.debug("Current location weather cache expired.")
                return nil
            }

            Logger.cache.debug("Loaded cached current location weather successfully.")
            return packet.bundle

        } catch {
            Logger.cache.error("Failed to load or decode current location weather cache: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    static func saveWeatherToCacheForCurrentLocation(_ bundle: WeatherBundles, location: CLLocation) {
        let packet = WeatherPacket(
            timestamp: Date(),
            coordinate: .init(lat: location.coordinate.latitude,
                              lon: location.coordinate.longitude),
            bundle: bundle)
        do {
            let data = try JSONEncoder().encode(packet)
            try filemanager.saveData(data, to: currentURL)
            Logger.cache.debug("Saved current location weather successfully to cache.")
        } catch {
            Logger.cache.error("Failed to save current location weather: \(error.localizedDescription, privacy: .public)")
        }
    }

    static func loadCachedWeatherForCityID(for city: City) -> WeatherBundles? {
        let url = url(for: city.id)
        guard filemanager.fileExists(at: url) else {
            Logger.cache.debug("No cached weather found for cityID: \(city.name)")
            return nil
        }

        do {
            let data = try filemanager.readData(from: url)
            let packet = try JSONDecoder().decode(WeatherPacket.self, from: data)

            let ageCheck = Date().timeIntervalSince(packet.timestamp) < expiry
            if !ageCheck {
                Logger.cache.debug("Cached weather for cityID: \(city.name) is expired.")
                return nil
            }

            Logger.cache.debug("Loaded cached weather for cityID: \(city.name)")
            return packet.bundle

        } catch {
            Logger.cache.error("Failed to load or decode cached weather for cityID: \(city.name): \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    static func saveWeatherToCacheForCity(_ bundle: WeatherBundles, for city: City) {
        let packet = WeatherPacket(timestamp: Date(),
                                   coordinate: .init(lat: 0, lon: 0),
                                   bundle: bundle)
        do {
            let data = try JSONEncoder().encode(packet)
            try filemanager.saveData(data, to: url(for: city.id))
            Logger.cache.debug("Saved cached weather for cityID: \(city.name)")
        } catch {
            Logger.cache.error("Failed to encode weather bundle for cityID: \(city.name): \(error.localizedDescription, privacy: .public)")
        }
    }
}
