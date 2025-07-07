//
//  LocationManager.swift
//  KumoCast
//
//  Created by Taylor on 7/6/25.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var cityName: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            userLocation = coordinate
            fetchCityName(for: coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func fetchCityName(for location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, error in
            if let placemark = placemarks?.first {
                self.cityName = placemark.locality
            } else {
                print("Reverse geocoding error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
