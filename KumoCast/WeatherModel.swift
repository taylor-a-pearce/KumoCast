//
//  WeatherModel.swift
//  KumoCast
//
//  Created by Taylor on 7/3/25.
//

struct WeatherModel: Codable {
    let airTemperature: Double
    let symbolCode1Hour: String?
    let symbolCode6Hour: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        airTemperature = try container.decode(Double.self, forKey: .airTemperature)
        symbolCode1Hour = try container.decodeIfPresent(String.self, forKey: .symbolCode1Hour)
        symbolCode6Hour = try container.decodeIfPresent(String.self, forKey: .symbolCode6Hour)
    }

    enum CodingKeys: String, CodingKey {
        case airTemperature
        case symbolCode1Hour
        case symbolCode6Hour
    }
}

struct MetNoResponse: Codable {
    let properties: Properties
}

struct Properties: Codable {
    let timeSeries: [TimeSeries]
}

struct TimeSeries: Codable {
    let weatherData: WeatherData
}

struct WeatherData: Codable {
    let instant: Instant
    let next1Hour: Next1Hour?
    let next6Hours: Next6Hours?
}

struct Instant: Codable {
    let details: Details
}

struct Details: Codable {
    let air_temperature: Double
}

struct Next1Hour: Codable {
    let summary: Summary
}

struct Next6Hours: Codable {
    let summary: Summary
}

struct Summary: Codable {
    let symbolCode: String
}
