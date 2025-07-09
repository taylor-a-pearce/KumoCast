//
//  SwiftUI_WeatherApp.swift
//  SwiftUI-Weather
//
//  Created by Taylor on 6/3/25.
//

import SwiftUI

@main
struct KumoCastApp: App {
    @State private var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                WeatherView()
            } else {
                LocationDeniedView()
            }
        }
        .environment(locationManager)
    }
}
