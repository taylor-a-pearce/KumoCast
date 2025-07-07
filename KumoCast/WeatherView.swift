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
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {

            BackgroundView(isNight: isNight)

            VStack {

                CityTextView(cityName: locationManager.cityName ?? "Locating...")

                MainWeatherView(imageName: sfSymbol(for: viewModel.weatherModel?.symbolCode1Hour ?? viewModel.weatherModel?.symbolCode6Hour ?? ""), temp: Int(viewModel.weatherModel?.airTemperature ?? 0) * 9 / 5 + 32)


//                Preview Code
//                MainWeatherView(imageName: "cloud.fill", temp: 92)

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
        .onChange(of: locationManager.userLocation) { newLocation in
            guard let location = newLocation else { return }
            Task {
                await viewModel.fetchWeatherIfNeeded(lat: location.latitude, lon: location.longitude)
                    print(viewModel.weatherModel?.airTemperature ?? 0)
                    print(viewModel.weatherModel?.symbolCode1Hour ?? "Failed1")
                    print(viewModel.weatherModel?.symbolCode6Hour ?? "Failed6")
                    print(viewModel.weatherModel?.symbolCode12Hour ?? "Failed12")
                    print(location.latitude)
                    print(location.longitude)
                }
            }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    if let location = locationManager.userLocation {
                        await viewModel.fetchWeatherIfNeeded(lat: location.latitude, lon: location.longitude)
                            print(viewModel.weatherModel?.airTemperature ?? 0)
                            print(viewModel.weatherModel?.symbolCode1Hour ?? "Failed1")
                            print(viewModel.weatherModel?.symbolCode6Hour ?? "Failed6")
                            print(viewModel.weatherModel?.symbolCode12Hour ?? "Failed12")
                            print(location.latitude)
                            print(location.longitude)
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
        var temp: Int

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: imageName)
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .foregroundColor(.white)
                Text("\(temp)°")
                    .font(.system(size: 70, weight: .medium, design: .default))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 40)
        }
    }
}

func sfSymbol(for symbolCode: String) -> String {
    switch symbolCode {

    // Clear / Fair
    case "clearsky_day", "fair_day":
        return "sun.max.fill"
    case "clearsky_night", "fair_night":
        return "moon.stars.fill"

    // Cloudy
    case "partlycloudy_day", "partlycloudy_night":
        return "cloud.sun.fill"
    case "cloudy":
        return "cloud.fill"

    // Rain Showers
    case "lightrain_showers_day", "lightrain_showers_night":
        return "cloud.drizzle.fill"
    case "rain_showers_day", "rain_showers_night":
        return "cloud.rain.fill"
    case "heavyrain_showers_day", "heavyrain_showers_night":
        return "cloud.heavyrain.fill"

    // Rain (Continuous)
    case "lightrain", "rain":
        return "cloud.rain.fill"
    case "heavyrain":
        return "cloud.heavyrain.fill"

    // Snow Showers
    case "lightsnow_showers_day", "lightsnow_showers_night":
        return "cloud.snow.fill"
    case "snow_showers_day", "snow_showers_night":
        return "cloud.snow.fill"
    case "heavysnow_showers_day", "heavysnow_showers_night":
        return "cloud.snow.fill"

    // Snow (Continuous)
    case "lightsnow", "snow", "heavysnow":
        return "cloud.snow.fill"

    // Thunderstorms
    case "lightning", "lightning_rainy", "lightning_showers_day", "lightning_showers_night":
        return "cloud.bolt.rain.fill"

    // Fog
    case "fog":
        return "cloud.fog.fill"

    // Fallback
    default:
        return "questionmark"
    }
}

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

#Preview {
    WeatherView()
}
