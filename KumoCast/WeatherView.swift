//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Taylor on 6/3/25.
//

import SwiftUI
import WeatherKit

struct WeatherView: View {

    @State private var isNight = false
    @StateObject private var viewModel = WeatherViewModel()
    @State private var isLoading = false
    let weatherManager = WeatherManager.shared

    @Environment(LocationManager.self) var locationManager
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedCity: City?
    @State private var currentCity: City?
    @State private var citiesListViewIsPresented: Bool = false
    @State private var timezone: TimeZone = .current

    private var displayCity: City? {
        selectedCity ?? currentCity
    }
    var highTemperature: String? {
        if let high = viewModel.hourlyWeather?.map({$0.temperature}).max() {
            return weatherManager.temperatureFormatter.string(from: high)
        } else {
            return nil
        }
    }

    var lowTemperature: String? {
        if let min = viewModel.hourlyWeather?.map({$0.temperature}).min() {
            return weatherManager.temperatureFormatter.string(from: min)
        } else {
            return nil
        }
    }

    var body: some View {
        ZStack {
            if displayCity == nil {
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
            } else if let displayCity, let currentWeather = viewModel.currentWeather {
                    VStack {
                        ScrollView(.vertical) {

                            CityTextView(cityName: displayCity.name)

                            MainWeatherView(
                                imageName: currentWeather.symbolName,
                                temp: WeatherManager.shared.temperatureFormatter.string(
                                    from: (currentWeather.temperature)
                                    .converted(to: .fahrenheit)
                                ),
                                highTemp: highTemperature,
                                lowTemp: lowTemperature

                            )
                            .padding(0)

                            if let hourlyForecast = viewModel.hourlyWeather {
                                HourlyForecastView(hourlyForecast: hourlyForecast, timezone: timezone)

                            }

                            if let dailyForecast = viewModel.dailyWeather {
                                DailyForecastView(dailyForecast: dailyForecast, timezone: timezone)
                            }

                            Spacer()

                        }
                        Button {
                            citiesListViewIsPresented.toggle()
                        } label: {
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 40)
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
        .task(id: locationManager.currentLocation) {
            if let currentLocation = locationManager.userLocation, selectedCity == nil {
                currentCity = locationManager.currentLocation
                Task {
                    await viewModel.fetchCurrentLocationWeather(for: currentLocation)
                }
            }
        }
        .task(id: currentCity?.id) {
            guard let _ = currentCity,
                  selectedCity == nil,
                  let location = locationManager.userLocation else { return }
            isLoading = true
            await viewModel.fetchCurrentLocationWeather(for: location)
            isLoading = false
        }

        .task(id: selectedCity) {
            if let selectedCity {
                isLoading = true
                Task {
                    await viewModel.fetchSelectedCityWeather(for: selectedCity)
                    isLoading = false
                }
            }
        }
        .fullScreenCover(isPresented: $citiesListViewIsPresented) {
            CitiesListView(currentLocation: locationManager.currentLocation, selectedCity: $selectedCity, currentCity: $currentCity)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if selectedCity == nil,
                   let location = locationManager.userLocation {
                    Task { await viewModel.fetchCurrentLocationWeather(for: location) }
                } else if let selectedCity = selectedCity {
                    Task { await viewModel.fetchSelectedCityWeather(for: selectedCity) }
                }
            }
        }
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
        var highTemp: String?
        var lowTemp: String?

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .symbolRenderingMode(.multicolor)
                    .symbolVariant(.fill)
                    .foregroundColor(.white)
                VStack {
                    Text("\(temp)")
                        .font(.system(size: 70, weight: .medium, design: .default))
                        .foregroundColor(.white)
                    if let highTemp, let lowTemp {
                        Text("H: \(highTemp) L:\(lowTemp)")
                            .bold()
                            .foregroundColor(.white)

                    }
                }
            }
            .padding(.bottom, 40)
        }
    }

    struct HourlyForecastView: View {
        let weatherManager = WeatherManager.shared
        let hourlyForecast: Forecast<HourWeather>
        let timezone: TimeZone

        var body: some View {
            VStack {
                Text("Hourly Forecast")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top)
                    .padding(.bottom, 0)

                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        ForEach(hourlyForecast, id: \.date) {
                            hour in
                            VStack(spacing: 0) {
                                Text(hour.date.localTime(for: timezone))
                                Spacer()
                                Image(systemName: hour.symbolName)
                                    .renderingMode(.original)
                                    .symbolVariant(.fill)
                                    .font(.system(size: 22))
                                    .padding(.bottom, 3)
                                if hour.precipitationChance > 0 {
                                    Text("\((hour.precipitationChance * 100).formatted(.number.precision(.fractionLength(0))))%")
                                        .foregroundStyle(.cyan)
                                        .bold()
                                }
                                Spacer()
                                Text(weatherManager.temperatureFormatter.string(from: hour.temperature))
                            }
                        }
                    }
                    .font(.system(size: 13))
                    .frame(height: 100)
                    .foregroundColor(.white)
                }
                .contentMargins(.all, 15, for: .scrollContent)

            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.3)))
            .padding(.horizontal)

        }
    }

struct DailyForecastView: View {
    let weatherManager = WeatherManager.shared
    let dailyForecast: Forecast<DayWeather>
    let timezone: TimeZone

    @State private var barWidth: Double = 0

    var body: some View {
            VStack {
                Text("10-Day Forecast")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top)

                VStack {
                    let maxDayTemp = dailyForecast.map{$0.highTemperature.value}.max() ?? 0
                    let minDayTemp = dailyForecast.map{$0.lowTemperature.value}.min() ?? 0

                    let tempRange = maxDayTemp - minDayTemp

                    ForEach(dailyForecast, id:\.date) {
                        day in
                        LabeledContent {
                            HStack(spacing: 0) {

                                VStack(spacing: 0) {
                                    Image(systemName: day.symbolName)
                                        .renderingMode(.original)
                                        .symbolVariant(.fill)
                                        .font(.system(size: 22))
                                        .padding(.bottom, 3)
                                    if day.precipitationChance > 0 {
                                        Text("\((day.precipitationChance * 100).formatted(.number.precision(.fractionLength(0))))%")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.cyan)
                                            .bold()
                                    }
                                }
                                .frame(width: 25)

                                Text(WeatherManager.shared.temperatureFormatter.string(from: day.lowTemperature))
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 50)

                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(height: 5)
                                    .readSize { size in
                                        barWidth = size.width
                                    }
                                    .overlay {
                                        let degreeFactor = barWidth / tempRange
                                        let dayRangeWidth = (day.highTemperature.value - day.lowTemperature.value) * degreeFactor
                                        let xOffset = (day.lowTemperature.value - minDayTemp) * degreeFactor
                                        HStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(
                                                            colors: [
                                                                .green,
                                                                .orange]
                                                        ),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: dayRangeWidth, height: 5)
                                            Spacer()
                                        }
                                        .offset(x: xOffset)
                                    }

                                Text(WeatherManager.shared.temperatureFormatter.string(from: day.highTemperature))
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 50)
                            }

                        } label: {
                            Text(day.date.localDay(for: timezone))
                                .frame(width: 50, alignment: .leading)
                        }
                        .frame(height: 35)

                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)

            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.3)))
            .padding()
        }
    }

#Preview {
    WeatherView()
        .environment(LocationManager())
        .environment(DataStore(forPreviews: true))
}
