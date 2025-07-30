//
//  LocationManager.swift
//  KumoCast
//
//  Created by Taylor on 7/6/25.
//

import CoreLocation
import Foundation
import os

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
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            Logger.location.info("Starting location updates...")
            manager.startUpdatingLocation()
            isAuthorized = true
        } else {
            Logger.location.debug("Location services not authorized. Requesting authorization...")
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        Logger.location.debug("Received location update: \(String(describing: self.userLocation))")

        if let userLocation {
            Task {
                let name = await getLocationName(for: userLocation)
                currentLocation = City(
                    name: name,
                    latitude: userLocation.coordinate.latitude,
                    longitude: userLocation.coordinate.longitude
                )
                Logger.location.info("Updated currentLocation to: \(name) [\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)]")
            }
        }
    }

    func getLocationName(for location: CLLocation) async -> String {
        let name = try? await CLGeocoder().reverseGeocodeLocation(location).first?.locality
        if let name {
            Logger.location.debug("Reverse geocoded name: \(name)")
        } else {
            Logger.location.error("Failed to reverse geocode name for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
        return name ?? ""
    }

    func getTimezone(for location: CLLocation) async -> TimeZone {
        let timezone = try? await CLGeocoder().reverseGeocodeLocation(location).first?.timeZone
        if let timezone {
            Logger.location.debug("Retrieved timezone: \(timezone.identifier)")
        } else {
            Logger.location.error("Failed to retrieve timezone for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
        return timezone ?? .current
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            Logger.location.info("Location authorized. Requesting location...")
            manager.requestLocation()
        case .notDetermined:
            isAuthorized = false
            Logger.location.debug("Location authorization not determined. Requesting permission...")
            manager.requestWhenInUseAuthorization()
        case .denied:
            isAuthorized = false
            Logger.location.error("Location access denied by user.")
        default:
            Logger.location.debug("Unhandled authorization status: \(manager.authorizationStatus.rawValue)")
            startLocationServices()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.location.error("Location update failed: \(error.localizedDescription, privacy: .public)")
    }
}
