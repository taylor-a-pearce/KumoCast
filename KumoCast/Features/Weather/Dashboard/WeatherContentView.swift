//
//  WeatherContentView.swift
//  KumoCast
//
//  Created by Taylor on 7/17/25.
//

import Foundation
import SwiftUI
import WeatherKit

struct WeatherContentView: View {
        let city: City
        let currentWeather: CurrentWeather
        let hourlyWeather: Forecast<HourWeather>?
        let dailyWeather:  Forecast<DayWeather>?
        let highTemp: String?
        let lowTemp:  String?
        let timezone: TimeZone
        let onShowCityList: () -> Void

    var body: some View {
            VStack {
                ScrollView(.vertical) {
                    MainWeatherView(
                        cityName: city.name, imageName: currentWeather.symbolName,
                        temp: WeatherManager.shared.temperatureFormatterWithUnit.string(
                            from: (currentWeather.temperature)
                        ),
                        highTemp: highTemp,
                        lowTemp: lowTemp

                    )
                    .padding(0)

                    if let hourlyForecast = hourlyWeather {
                        HourlyForecastView(hourlyForecast: hourlyForecast, timezone: timezone)

                    }

                    if let dailyForecast = dailyWeather {
                        DailyForecastView(dailyForecast: dailyForecast, timezone: timezone)
                    }

                    Spacer()

                }
                Button {
                    onShowCityList()
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
