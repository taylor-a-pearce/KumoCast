//
//  WeatherModel.swift
//  KumoCast
//
//  Created by Taylor on 7/7/25.
//

import WeatherKit
import Foundation

struct WeatherBundles: Codable {
    let current: CurrentWeather
    let hourly: Forecast<HourWeather>
    let daily: Forecast<DayWeather>
}
