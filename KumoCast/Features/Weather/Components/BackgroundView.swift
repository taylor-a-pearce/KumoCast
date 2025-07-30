//
//  Untitled.swift
//  KumoCast
//
//  Created by Taylor on 7/9/25.
//

import Foundation
import SwiftUI
import WeatherKit

struct BackgroundView: View {
    let condition: WeatherCondition
    @State private var animate = false

    var body: some View {
        Image(condition.imageKey)
            .resizable()
            .scaledToFill()
            .offset(x: animate ? -10 : 10, y: animate ? -10 : 10)
//            .blur(radius: 5)
//            .colorMultiply(.white.opacity(0.8))
            .animation(
                Animation.easeInOut(duration: 20)
                    .repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear {
                animate = true
            }
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView(condition: .sunShowers)
}

extension WeatherCondition {
    /// A simplified image key representing grouped weather visuals
    var imageKey: String {
        switch self {
        case .clear, .mostlyClear, .sunShowers, .sunFlurries:
            return "AnimeSunny"

        case .partlyCloudy, .mostlyCloudy:
            return "AnimePartlyCloudy"

        case .cloudy:
            return "AnimeCloudy"

        case .foggy, .haze, .smoky, .blowingDust:
            return "AnimeFoggy"

        case .breezy, .windy, .blowingSnow:
            return "windy"

        case .drizzle, .rain, .freezingDrizzle, .freezingRain:
            return "AnimeRain"

        case .heavyRain:
            return "AnimeHeavyRain"

        case .flurries, .snow, .sleet, .wintryMix:
            return "snow"

        case .heavySnow, .blizzard:
            return "heavySnow"

        case .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms, .thunderstorms:
            return "thunderstorm"

        case .hurricane, .tropicalStorm:
            return "severeStorm"

        case .frigid:
            return "frigid"

        case .hot:
            return "hot"

        case .hail:
            return "hail"
        @unknown default:
            return "sunny"
        }
    }
}
