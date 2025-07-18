//
//  CityListView.swift
//  KumoCast
//
//  Created by Taylor on 7/8/25.
//

import Foundation
import SwiftUI

struct CitiesListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(DataStore.self) private var store
    let currentLocation: City?
    @Binding var selectedCity: City?

    @State private var isSearching = false
    @FocusState private var isFocused: Bool


    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: .constant(""))
                            .textFieldStyle(.roundedBorder)
                            .focused($isFocused)
                            .onChange(of: isFocused) { _, focused in
                                if focused {
                                     isSearching = true
                                }
                            }
                    }
                    .padding()
                    List {
                        Group {
                            if let currentLocation {
                                CityRowView(city: currentLocation, isCurrentLocation: true)
                                    .onTapGesture {
                                        selectedCity = nil
                                        dismiss()
                                    }
                            }
                            ForEach(store.cities.sorted(using: KeyPathComparator(\.name))) { city in
                                CityRowView(city: city)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            if let index = store.cities.firstIndex(where: {$0.id == city.id }) {
                                                store.cities.remove(at: index)
                                                store.saveCities()
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .onTapGesture {
                                        selectedCity = city
                                        dismiss()
                                    }
                                }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .listRowInsets(.init(top: 0, leading: 20, bottom: 5, trailing: 20))
                        }
                    .listStyle(.plain)
                    .navigationTitle(LocalizedStringKey("My Cities"))
                    .navigationBarTitleDisplayMode(.inline)
                }
                if isSearching {
                    SearchOverlay(isSearching: $isSearching)
                        .zIndex(1.0)
                }
            }
            }
        }
    }

#Preview {
    CitiesListView(currentLocation: City.mockCity, selectedCity: .constant(nil))
        .environment(LocationManager())
        .environment(DataStore(forPreviews: true))
}
