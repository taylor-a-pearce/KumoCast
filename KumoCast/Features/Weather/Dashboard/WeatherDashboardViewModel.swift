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
            return WeatherManager.shared.temperatureFormatterNoUnit.string(from: NSNumber(value: high.value))
        } else {
            return nil
        }
    }

    var lowTemperature: String? {
        if let min = hourlyWeather?.map({$0.temperature}).min() {
            return WeatherManager.shared.temperatureFormatterNoUnit.string(from: NSNumber(value: min.value))
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
        if let cached = WeatherCacheManager.loadCachedWeatherForCityID(for: city) {
            applyCache(bundle: cached)
            return
        }
        do {
            let bundle = try await weatherManager.fetchWeatherBundles(
                for: .init(latitude: city.latitude,
                           longitude: city.longitude))
            WeatherCacheManager.saveWeatherToCacheForCity(bundle, for: city)
            applyCache(bundle: bundle)

        } catch {
            print(error)
        }
    }

    func fetchCurrentLocationWeather(for location: CLLocation) async {
        if let cached = WeatherCacheManager.loadCachedWeatherForCurrentLocation(from: location) {
            applyCache(bundle: cached)
            return
        }
        do {
            let bundle = try await weatherManager.fetchWeatherBundles(
                for: .init(latitude: location.coordinate.latitude,
                           longitude: location.coordinate.longitude))
            WeatherCacheManager.saveWeatherToCacheForCurrentLocation(bundle, location: location)
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
