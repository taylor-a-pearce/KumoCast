//
//  WeatherViewModel.swift
//  KumoCast
//
//  Created by Taylor on 7/3/25.
//

import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weatherModel: WeatherModel?


    private let lastFetchKey = "lastFetchDate"
    private let weatherDataKey = "cachedWeatherData"

    private var lastFetchDate: Date? {
        get {
            UserDefaults.standard.object(forKey: lastFetchKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastFetchKey)
        }
    }

    private func saveWeatherToCache(_ weather: WeatherModel) {
        if let encoded = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(encoded, forKey: weatherDataKey)
        }
    }

    private func loadWeatherFromCache() -> WeatherModel? {
        if let cachedData = UserDefaults.standard.data(forKey: weatherDataKey),
           let cachedWeather = try? JSONDecoder().decode(WeatherModel.self, from: cachedData) {
            return cachedWeather
        }
        return nil
    }

    func fetchWeatherIfNeeded(lat: Double, lon: Double) async {
        let now = Date()
        if let lastFetch = lastFetchDate, now.timeIntervalSince(lastFetch) < 1800 {
            print("Using cached weather data (less than 30 minutes old).")
            if let cachedWeather = loadWeatherFromCache() {
                weatherModel = cachedWeather
                return
            } else {
                print("Cached weather data missing or corrupted, refetching from API")
            }
        }
        do {
            weatherModel = try await getWeatherData(lat: lat, lon: lon)
            if let weatherModel = weatherModel {
                saveWeatherToCache(weatherModel)
            }
            lastFetchDate = now
            print("Fetched new weather data from API.")
        } catch {
            print("Error fetching weather data: \(error.localizedDescription)")
        }
    }
}
