//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Taylor on 6/3/25.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherDashboardView: View {

    @State private var isNight = false
    @StateObject private var viewModel = WeatherDashboardViewModel()
    @State private var isLoading = false
    let weatherManager = WeatherManager.shared

    @Environment(LocationManager.self) var locationManager
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedCity: City?
    @State private var currentCity: City?
    @State private var citiesListViewIsPresented: Bool = false
    @State private var timezone: TimeZone = .current

    private var displayCity: City? {
        selectedCity ?? locationManager.currentLocation
    }

    private enum ScreenState {
        case locating
        case fetching
        case ready
    }

    // MARK: - Selection for refresh logic
    enum Selection: Hashable {
        case current(CLLocation)   // GPS coordinate
        case selectedCity(City)    // whole City object
        case none
    }

    private var selectionKey: Selection {
        if let city = selectedCity {
            return .selectedCity(city)
        } else if let location = locationManager.userLocation {
            return .current(location)
        } else {
            return .none
        }
    }

    private var screenState: ScreenState {
        if displayCity == nil {
            return .locating
        } else if isLoading {
            return .fetching
        } else {
            return .ready
        }
    }

    var body: some View {
        ZStack {
            switch screenState {
            case .locating:
                LoadingView(text: "Locating...")
            case .fetching:
                LoadingView(text: "Fetching weather...")
            case .ready:
                if let displayCity,
                   let currentWeather = viewModel.currentWeather {
                    WeatherContentView(
                        city: displayCity,
                        currentWeather: currentWeather,
                        hourlyWeather: viewModel.hourlyWeather,
                        dailyWeather: viewModel.dailyWeather,
                        highTemp: viewModel.highTemperature,
                        lowTemp: viewModel.lowTemperature,
                        timezone: timezone,
                        onShowCityList: { citiesListViewIsPresented.toggle() }
                    )
                }
            }
        }
        .background {
            if displayCity != nil {
                if let condition = viewModel.currentWeather?.condition {
                    BackgroundView(condition: condition)
                }
            }
        }
        .task(id: selectionKey) {
            if selectionKey != .none {
                isLoading = true
                await viewModel.refresh(for: selectionKey)
                isLoading = false
            }
        }
        .fullScreenCover(isPresented: $citiesListViewIsPresented) {
            CitiesListView(currentLocation: locationManager.currentLocation, selectedCity: $selectedCity)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active && selectionKey != .none {
                Task { await viewModel.refresh(for: selectionKey) }
            }
        }
    }
}

#Preview {
    WeatherDashboardView()
        .environment(LocationManager())
        .environment(DataStore(forPreviews: true))
}
