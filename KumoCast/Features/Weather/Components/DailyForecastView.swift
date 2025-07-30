//
//  DailyForecastView.swift
//  KumoCast
//
//  Created by Taylor on 7/17/25.
//
import Foundation
import SwiftUI
import WeatherKit

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

                            Text(WeatherManager.shared.temperatureFormatterWithUnit.string(from: day.lowTemperature))
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

                            Text(WeatherManager.shared.temperatureFormatterWithUnit.string(from: day.highTemperature))
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
