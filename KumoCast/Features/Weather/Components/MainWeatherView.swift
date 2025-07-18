//
//  MainWeatherView.swift
//  KumoCast
//
//  Created by Taylor on 7/17/25.
//
import Foundation
import SwiftUI

struct MainWeatherView: View {
    var cityName: String
    var imageName: String
    var temp: String
    var highTemp: String?
    var lowTemp: String?

    var body: some View {
        Text(cityName)
            .font(.system(size: 32, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding(.top, 70)
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
