//
//  CityRowView.swift
//  KumoCast
//
//  Created by Taylor on 7/10/25.
//

import SwiftUI
import Foundation
import WeatherKit

struct CityRowView: View {
    @StateObject private var viewModel = WeatherDashboardViewModel()
    @Environment(LocationManager.self) var locationManager
    @State private var isLoading: Bool = false
    @State private var timezone: TimeZone = .current
    let city: City
    var isCurrentLocation: Bool = false

    var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(city.name)
                            .font(.title)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(viewModel.currentWeather?.date.localTime(for: timezone) ?? "")
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(WeatherManager.shared.temperatureFormatterWithUnit.string(from: (viewModel.currentWeather?.temperature
                                                                                  ?? Measurement(value: 0, unit: UnitTemperature.celsius))
                        ))
                    .font(.system(size: 60, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                }
                Text(viewModel.currentWeather?.condition.description ?? "")
                    .foregroundColor(.white)
                }

        .padding()
        .frame(maxWidth: .infinity)

        .background {
                if let condition = viewModel.currentWeather?.condition {
                    BackgroundView(condition: condition)
                        .scaleEffect(1.25)
                        // keep anything that hangs outside the row from spilling over
                        .clipped()
                }
        }
        .task(id: city) {
            Task {
                if isCurrentLocation, let location = locationManager.userLocation {
                    await viewModel.fetchCurrentLocationWeather(for: location)
                } else {
                    await viewModel.fetchSelectedCityWeather(for: city)
                }
                timezone = await locationManager.getTimezone(for: city.clLocation)
            }
        }
    }
}

#Preview {
    CityRowView(city: City.mockCity)
        .environment(LocationManager())
}
