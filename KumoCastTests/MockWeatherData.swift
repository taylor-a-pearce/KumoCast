//
//  MockWeatherData.swift
//  KumoCast
//
//  Created by Taylor on 7/22/25.
//

import Foundation
import WeatherKit
import CoreLocation
@testable import KumoCast

struct MockWeatherPacket {
    let current: MockCurrentWeather
    let hourly: [MockHourWeather]
    let daily: [MockDayWeather]
}

struct MockCurrentWeather {
    let temperature: Double
    let condition: String
    let timestamp: Date
}

struct MockHourWeather {
    let temperature: Double
    let condition: String
    let timestamp: Date
}

struct MockDayWeather {
    let high: Double
    let low: Double
    let condition: String
    let date: Date
}

//struct MockWeatherData {
//    static let bundle = WeatherBundles(
//        current: WeatherBundles.current(
//            temperature: 30.5,
//            condition: "Cloudy",
//            timestamp: Date()
//        ),
//        hourly: [
//            MockHourWeather(temperature: 29.8, condition: "Mostly Clear", timestamp: Date())
//        ],
//        daily: [
//            MockDayWeather(high: 31.7, low: 21.0, condition: "Drizzle", date: Date())
//        ]
//    )
//}
