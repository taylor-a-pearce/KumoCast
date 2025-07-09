//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Taylor on 6/3/25.
//

import SwiftUI

struct WeatherView: View {

    @State private var isNight = false
    @StateObject private var viewModel = WeatherViewModel()
    @State private var isLoading = false

    @Environment(LocationManager.self) var locationManager
    @State private var selectedCity: City?

    var body: some View {
        ZStack {

            BackgroundView(isNight: isNight)

            if selectedCity == nil {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Locating…")
                    }
                    .foregroundColor(.white)
                } else if isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Fetching weather…")
                    }
                    .foregroundColor(.white)
            } else if let selectedCity {
                if let current = viewModel.current {
                    VStack {

                        CityTextView(cityName: selectedCity.name)

                        MainWeatherView(
                            imageName: viewModel.current?.symbolName ?? "cloud.fill",
                            temp: WeatherManager.shared.temperatureFormatter.string(
                                from: (viewModel.current?.temperature
                                       ?? Measurement(value: 0, unit: UnitTemperature.celsius))
                                .converted(to: .fahrenheit)
                            )
                        )

                        //                HStack(spacing: 20) {
                        //                    weatherOfDay(day: "Weds", image: "cloud.fill", temp: 55)
                        //                    weatherOfDay(day: "Thurs", image: "sun.max.fill", temp: 72)
                        //                    weatherOfDay(day: "Fri", image: "cloud.sun.fill", temp: 67)
                        //                    weatherOfDay(day: "Sat", image: "cloud.rain.fill", temp: 33)
                        //                    weatherOfDay(day: "Sun", image: "cloud.snow.fill", temp: 21)
                        //                }

                        Spacer()
                    }
                }
            }
        }
        .task(id: locationManager.currentLocation) {
            if let currentLocation = locationManager.currentLocation, selectedCity == nil {
                selectedCity = currentLocation
            }
        }

        .task(id: selectedCity) {
            if let selectedCity {
                isLoading = true
                Task {
                    await viewModel.fetchWeatherIfNeeded(
                        lat: selectedCity.clLocation.coordinate.latitude,
                        lon: selectedCity.clLocation.coordinate.longitude)
                    isLoading = false
                }
            }
        }
    }
    }
    struct weatherOfDay: View {
        var day: String
        var image: String
        var temp: Int

        var body: some View {
            VStack {
                Text(day)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Image(systemName: image)
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                Text("\(temp)°")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
    struct BackgroundView: View {

        var isNight: Bool

        var body: some View {
            LinearGradient(gradient: Gradient(colors: [isNight ? .black : Color("darkerBlue"), isNight ? .gray : Color("lightBlue")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }

    struct CityTextView: View {
        var cityName: String
        var body: some View {
            Text(cityName)
                .font(.system(size: 32, weight: .medium, design: .default))
                .foregroundColor(.white)
                .padding(.top, 70)
        }
    }

    struct MainWeatherView: View {
        var imageName: String
        var temp: String

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .symbolRenderingMode(.multicolor)
                    .symbolVariant(.fill)
                    .foregroundColor(.white)
                Text("\(temp)")
                    .font(.system(size: 70, weight: .medium, design: .default))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 40)
        }
    }

#Preview {
    WeatherView()
        .environment(LocationManager())
}
