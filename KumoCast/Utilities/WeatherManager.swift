//
//  WeatherManager.swift
//  KumoCast
//
//  Created by Taylor on 7/7/25.
//

import Foundation
import WeatherKit
import CoreLocation
import os

class WeatherManager {
    static let shared = WeatherManager()
    let service = WeatherService.shared

    var temperatureFormatterWithUnit: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitOptions = .naturalScale 
        return formatter
    }()

    var temperatureFormatterNoUnit: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    func fetchWeatherBundles(for coordinate:CLLocationCoordinate2D) async throws -> WeatherBundles {

        Logger.weather.info("Fetching weather for lat: \(coordinate.latitude), lon: \(coordinate.longitude)")
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        async let current = service.weather(for: location, including: .current)

        async let hourly = service.weather(for: location, including: .hourly)

        async let daily = service.weather(for: location, including: .daily)

        do {
            let bundle = try await WeatherBundles(current: current, hourly: hourly, daily: daily)
            Logger.weather.debug("Successfully fetched all weather bundles.")
            Logger.weather.debug("""
            Weather bundle contents:
            Current: \(String(describing: bundle.current))
            Hourly: \(String(describing: bundle.hourly))
            Daily: \(String(describing: bundle.daily))
            """)
            return bundle
        } catch {
            Logger.weather.error("Failed to fetch weather bundles: \(error.localizedDescription)")
            throw error
        }
    }
}
