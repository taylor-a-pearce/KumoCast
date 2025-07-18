//
//  WeatherViewModel.swift
//  KumoCast
//
//  Created by Taylor on 7/7/25.
//

import Foundation
import WeatherKit
import SwiftUI
import CoreLocation

@MainActor
final class WeatherDashboardViewModel: ObservableObject {
    @Published var currentWeather: CurrentWeather?
    @Published var hourlyWeather: Forecast<HourWeather>?
    @Published var dailyWeather: Forecast<DayWeather>?

    private let weatherManager = WeatherManager.shared

    var highTemperature: String? {
        if let high = hourlyWeather?.map({$0.temperature}).max() {
            return weatherManager.temperatureFormatter.string(from: high)
        } else {
            return nil
        }
    }

    var lowTemperature: String? {
        if let min = hourlyWeather?.map({$0.temperature}).min() {
            return weatherManager.temperatureFormatter.string(from: min)
        } else {
            return nil
        }
    }

    private func applyCache(bundle: WeatherBundles) {
        currentWeather = bundle.current
        hourlyWeather = bundle.hourly
        dailyWeather = bundle.daily
    }

    func fetchSelectedCityWeather(for city: City) async {
        if let cached = WeatherCacheManager.load(for: city.id) {
            applyCache(bundle: cached)
            print("🟢 Loaded from Cache for \(city.name)")
            return
        }
        do {
            let bundle = try await weatherManager.fetchWeatherBundles(
                for: .init(latitude: city.latitude,
                           longitude: city.longitude))
            WeatherCacheManager.save(bundle, for: city.id)
            print("🔴 Called WeatherKit API for \(city.name)")
            applyCache(bundle: bundle)

        } catch {
            print(error)
        }
    }

    func fetchCurrentLocationWeather(for location: CLLocation) async {
        if let cached = WeatherCacheManager.loadCurrent(for: location) {
            applyCache(bundle: cached)
            print("🟢 Loaded from Cache for Current Location")
            return
        }
        do {
            let bundle = try await weatherManager.fetchWeatherBundles(
                for: .init(latitude: location.coordinate.latitude,
                           longitude: location.coordinate.longitude))
            WeatherCacheManager.saveCurrent(bundle, location: location)
            print("🔴 Called WeatherKit API for Current Location")
            applyCache(bundle: bundle)
        } catch {
            print(error)
        }
    }

    func refresh(for selection: WeatherDashboardView.Selection) async {
        switch selection {

        case .selectedCity(let city):
            await fetchSelectedCityWeather(for: city)

        case .current(let location):
            await fetchCurrentLocationWeather(for: location)

        case .none:
            break
        }
    }
}
