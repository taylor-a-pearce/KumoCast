//
//  WeatherViewModel.swift
//  KumoCast
//
//  Created by Taylor on 7/7/25.
//

import Foundation
import WeatherKit

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var current: CurrentWeather?
    @Published var hourly: Forecast<HourWeather>?
    @Published var daily: Forecast<DayWeather>?


    private let stampKey = "WeatherLastFetch"
    private let weatherDataKey = "WeatherCachedData"

    private var lastFetchDate: Date? {
        get {
            UserDefaults.standard.object(forKey: stampKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: stampKey)
        }
    }

    private func saveWeatherToCache(_ weather: WeatherBundles) {
        if let data = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(data, forKey: weatherDataKey)
        }
    }

    private func loadWeatherFromCache() -> WeatherBundles? {
            guard let data = UserDefaults.standard.data(forKey: weatherDataKey) else { return nil }
            return try? JSONDecoder().decode(WeatherBundles.self, from: data)
        }

    func fetchWeatherIfNeeded(lat: Double, lon: Double) async {
        let now = Date()
        if let lastFetch = lastFetchDate, now.timeIntervalSince(lastFetch) < 600 {
            print("Using cached weather data (less than 10 minutes old).")
            if let cachedWeather = loadWeatherFromCache() {
                self.current = cachedWeather.current
                self.hourly = cachedWeather.hourly
                self.daily = cachedWeather.daily
                return
            } else {
                print("Cached weather data missing or corrupted, refetching from API")
            }
        }
        do {
            let bundle = try await WeatherManager.shared.fetchWeatherBundles(for: .init(latitude: lat, longitude: lon)
            )
            self.current = bundle.current
            self.hourly = bundle.hourly
            self.daily = bundle.daily
            saveWeatherToCache(bundle)
            lastFetchDate = now
            print("Fetched new weather data from API.")
        } catch {
            print("Error fetching weather data: \(error.localizedDescription)")
        }
    }
}
