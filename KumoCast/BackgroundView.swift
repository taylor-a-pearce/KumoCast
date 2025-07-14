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

    var body: some View {
        Image(condition.rawValue)
            .blur(radius: 5)
            .colorMultiply(.white.opacity(0.8))

    }
}

#Preview {
    BackgroundView(condition: .sunShowers)
}
