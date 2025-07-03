//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Taylor on 6/3/25.
//

import SwiftUI

struct WeatherView: View {

    @State private var isNight = false

    var body: some View {
        ZStack {

            BackgroundView(isNight: isNight)

            VStack {

                CityTextView(cityName: "Denver")

                MainWeatherView(imageName: isNight ? "moon.stars.fill" : "cloud.sun.fill", temp: 82)

                HStack(spacing: 20) {
                    weatherOfDay(day: "Weds", image: "cloud.fill", temp: 55)
                    weatherOfDay(day: "Thurs", image: "sun.max.fill", temp: 72)
                    weatherOfDay(day: "Fri", image: "cloud.sun.fill", temp: 67)
                    weatherOfDay(day: "Sat", image: "cloud.rain.fill", temp: 33)
                    weatherOfDay(day: "Sun", image: "cloud.snow.fill", temp: 21)
                }

                Spacer()

                Button {
                    isNight.toggle()
                } label: {
                    WeatherButton(title: "Change Day Time", textColor: Color.blue, backgroundColor: Color.white)
                }

                Spacer()
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
            LinearGradient(gradient: Gradient(colors: [isNight ? .black : .blue, isNight ? .gray : Color("lightBlue")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }

    struct CityTextView: View {
        var cityName: String
        var body: some View {
            Text("Denver, CO")
                .font(.system(size: 32, weight: .medium, design: .default))
                .foregroundColor(.white)
                .padding()
        }
    }

    struct MainWeatherView: View {
        var imageName: String
        var temp: Int

        var body: some View {
            VStack(spacing: 8) {
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

#Preview {
    WeatherView()
}
