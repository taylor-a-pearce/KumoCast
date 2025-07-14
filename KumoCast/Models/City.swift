//
//  City.swift
//  KumoCast
//
//  Created by Taylor on 7/7/25.
//
import Foundation
import CoreLocation

struct City: Identifiable, Hashable, Codable {
    var id = UUID ()
    var name: String
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D (latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation (latitude: latitude, longitude: longitude)
    }

    static var mockCity: City = .init (
        name: "Denver",
        latitude: 39.7392,
        longitude: -104.9903
    )

    static var mockCityList: [City] = [
        .init(name: "New York", latitude: 40.7128, longitude: -74.0060),
        .init(name: "Los Angeles", latitude: 34.0522, longitude: -118.2437),
        .init(name: "Chicago", latitude: 41.8781, longitude: -87.6298),
        .init(name: "Houston", latitude: 29.7604, longitude: -95.3698),
        ]
}
