//
//  WebApp.swift
//  SwiftUI-Weather
//
//  Created by Taylor on 7/2/25.
//

import Foundation

func getWeatherData(lat: Double, lon: Double) async throws -> WeatherModel {
    let endpoint = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)"

    guard let url = URL(string: endpoint) else {
        fatalError("Invalid URL: \(endpoint)")
    }

    var request = URLRequest(url: url)
    request.setValue("KumoCast/1.0 (taylor.a.pearce@gmail.com)", forHTTPHeaderField: "User-Agent")

    let (responseBodyData, response) = try await URLSession.shared.data(for: request)

    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        fatalError("Failed to fetch weather data")
    }

    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decodedResponse = try decoder.decode(MetNoResponse.self, from: responseBodyData)

        guard let firstTimeSeries = decodedResponse.properties.timeseries.first else {
            fatalError("No forecast data available")
        }

        let weatherData = firstTimeSeries.data
        let airTemp = weatherData.instant.details.airTemperature
        let symbol1Hour = weatherData.next1Hours?.summary.symbolCode
        let symbol6Hour = weatherData.next6Hours?.summary.symbolCode
        let symbol12Hour = weatherData.next12Hours?.summary.symbolCode

        return WeatherModel(
                    airTemperature: airTemp,
                    symbolCode1Hour: symbol1Hour,
                    symbolCode6Hour: symbol6Hour,
                    symbolCode12Hour: symbol12Hour
                )
    } catch {
        fatalError("Failed to decode weather data: \(error)")
    }
}
