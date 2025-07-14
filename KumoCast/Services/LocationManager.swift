//
//  LocationManager.swift
//  KumoCast
//
//  Created by Taylor on 7/6/25.
//

import CoreLocation
import Foundation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored let manager = CLLocationManager()
    var userLocation: CLLocation?
    var currentLocation: City?
    var isAuthorized = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func startLocationServices() {
        if manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            isAuthorized = true
        } else {
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        if let userLocation {
            Task {
                let name = await getLocationName(for: userLocation)
                currentLocation = City(
                    name: name,
                    latitude: userLocation.coordinate.latitude,
                    longitude: userLocation.coordinate.longitude
                )
            }
        }
    }

    func getLocationName(for location: CLLocation) async -> String {
        let name = try? await CLGeocoder().reverseGeocodeLocation(location).first?.locality
        return name ?? ""
    }

    func getTimezone(for location: CLLocation) async -> TimeZone {
        let timezone = try? await CLGeocoder().reverseGeocodeLocation(location).first?.timeZone
        return timezone ?? .current
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            manager.requestLocation()
        case .notDetermined:
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        case .denied:
            isAuthorized = false
        default:
            startLocationServices()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let manager = CLLocationManager()
//    @Published var userLocation: CLLocationCoordinate2D?
//    @Published var cityName: String?
//
//    override init() {
//        super.init()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyKilometer
//        manager.requestWhenInUseAuthorization()
//        manager.requestLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let coordinate = locations.first?.coordinate {
//            userLocation = coordinate
//            fetchCityName(for: coordinate)
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Location error: \(error.localizedDescription)")
//    }
//
//    func fetchCityName(for location: CLLocationCoordinate2D) {
//        let geocoder = CLGeocoder()
//        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
//        geocoder.reverseGeocodeLocation(loc) { placemarks, error in
//            if let placemark = placemarks?.first {
//                self.cityName = placemark.locality
//            } else {
//                print("Reverse geocoding error: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }
//    }
//}
