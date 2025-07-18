//
//  WeatherManager.swift
//  KumoCast
//
//  Created by Taylor on 7/7/25.
//

import Foundation
import WeatherKit
import CoreLocation

class WeatherManager {
    static let shared = WeatherManager()
    let service = WeatherService.shared

    var temperatureFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()

    func fetchWeatherBundles(for coordinate:CLLocationCoordinate2D) async throws -> WeatherBundles {

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        async let current = service.weather(for: location, including: .current)
        async let hourly = service.weather(for: location, including: .hourly)
        async let daily = service.weather(for: location, including: .daily)

        return try await WeatherBundles(current: current, hourly: hourly, daily: daily)
    }
}
