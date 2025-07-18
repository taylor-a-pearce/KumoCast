//
//  LoadingView.swift
//  KumoCast
//
//  Created by Taylor on 7/17/25.
//
import Foundation
import SwiftUI

struct LoadingView: View {
    var text: String
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text(text)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
