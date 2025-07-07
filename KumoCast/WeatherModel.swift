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
    let symbolCode12Hour: String?
}

struct MetNoResponse: Codable {
    let properties: Properties
}

struct Properties: Codable {
    let timeseries: [Timeseries]
}

struct Timeseries: Codable {
    let data: WeatherData
}

struct WeatherData: Codable {
    let instant: Instant
    let next1Hours: Next1Hours?
    let next6Hours: Next6Hours?
    let next12Hours: Next12Hours?
}

struct Instant: Codable {
    let details: Details
}

struct Details: Codable {
    let airTemperature: Double
}

struct Next1Hours: Codable {
    let summary: Summary
}

struct Next6Hours: Codable {
    let summary: Summary
}

struct Next12Hours: Codable {
    let summary: Summary
}

struct Summary: Codable {
    let symbolCode: String
}
